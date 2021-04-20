// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/SafeERC20.sol';
import './base/Importable.sol';
import './base/ExternalStorable.sol';
import './interfaces/IEscrow.sol';
import './interfaces/storages/IEscrowStorage.sol';
import './interfaces/ISynbitToken.sol';
import './interfaces/IERC20.sol';

contract Escrow is Importable, ExternalStorable, IEscrow {
    using SafeMath for uint256;
    using PreciseMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 private constant BALANCE = 'Balance';
    bytes32 private constant STAKED = 'Staked';
    bytes32 private constant WITHDRAWN = 'Withdrawn';
    bytes32[] private ESCROW_CONTRACTS = [
        CONTRACT_SUPPLY_SCHEDULE,
        CONTRACT_STAKER,
        CONTRACT_PROVIDER,
        CONTRACT_SPECIAL
    ];
    bytes32[] private CROWDSALE_CONTRACTS = [CONTRACT_CROWDSALE];

    uint256 public escrowDuration = 90 days;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_ESCROW);
        imports = [
            CONTRACT_SYNBIT,
            CONTRACT_SYNBIT_TOKEN,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_STAKER,
            CONTRACT_PROVIDER,
            CONTRACT_SPECIAL,
            CONTRACT_CROWDSALE
        ];
    }

    function Storage() internal view returns (IEscrowStorage) {
        return IEscrowStorage(getStorage());
    }

    function setEscrowDuration(uint256 duration) external onlyOwner {
        emit EscrowDurationChanged(escrowDuration, duration);
        escrowDuration = duration;
    }

    function deposit(
        uint256 period,
        address account,
        uint256 amount
    ) external containAddressOrOwner(ESCROW_CONTRACTS) returns (uint256 vestTime) {
        vestTime = now.add(escrowDuration);
        Storage().incrementUint(BALANCE, account, amount);
        Storage().setEscrow(account, period, amount, vestTime);
    }

    function deposit(
        uint256 period,
        address account,
        uint256 amount,
        uint256 vestTime
    ) external containAddressOrOwner(CROWDSALE_CONTRACTS) {
        IERC20(requireAddress(CONTRACT_SYNBIT_TOKEN)).safeTransferFrom(msg.sender, address(this), amount);

        Storage().incrementUint(BALANCE, account, amount);
        Storage().setEscrow(account, period, amount, vestTime);
    }

    function withdraw(address account, uint256 amount) external onlyAddress(CONTRACT_SYNBIT) {
        uint256 withdrawable = getWithdrawable(account);
        withdrawable.sub(amount, 'Escrow: withdraw amount exceeds withdrawable');
        Storage().decrementUint(BALANCE, account, amount, 'Escrow: withdraw amount exceeds balance');

        Storage().incrementUint(WITHDRAWN, account, amount);
        IERC20(requireAddress(CONTRACT_SYNBIT_TOKEN)).safeTransfer(account, amount);
    }

    function stake(address account, uint256 amount) external onlyAddress(CONTRACT_SYNBIT) {
        getAvailable(account).sub(amount, 'Escrow: stake amount exceeds available');
        Storage().incrementUint(STAKED, account, amount);
    }

    function unstake(address account, uint256 amount) external onlyAddress(CONTRACT_SYNBIT) {
        Storage().decrementUint(STAKED, account, amount, 'Escrow: unstake amount exceeds staked');
    }

    function getWithdrawable(address account) public view returns (uint256) {
        uint256 currentPeriod = SupplySchedule().currentPeriod();
        uint256 withdrawn = Storage().getUint(WITHDRAWN, account);
        uint256 available = getAvailable(account);
        uint256 withdrawable = 0;
        for (uint256 i = 0; i < currentPeriod; i++) {
            (uint256 amount, uint256 vestTime) = Storage().getEscrow(account, i);
            if (vestTime > now || vestTime == 0) continue;
            withdrawable = withdrawable.add(amount);
        }
        if (withdrawable <= withdrawn) return 0;
        return withdrawable.sub(withdrawn).min(available);
    }

    function getAvailable(address account) public view returns (uint256) {
        uint256 balance = getBalance(account);
        uint256 staked = getStaked(account);
        if (staked >= balance) return 0;
        return balance.sub(staked);
    }

    function getBalance(address account) public view returns (uint256) {
        return Storage().getUint(BALANCE, account);
    }

    function getStaked(address account) public view returns (uint256) {
        return Storage().getUint(STAKED, account);
    }
}
