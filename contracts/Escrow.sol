// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/SafeERC20.sol';
import './base/Importable.sol';
import './base/ExternalStorable.sol';
import './interfaces/IEscrow.sol';
import './interfaces/storages/IEscrowStorage.sol';
import './interfaces/ISynthxToken.sol';
import './interfaces/IERC20.sol';

contract Escrow is Importable, ExternalStorable, IEscrow {
    using SafeMath for uint256;
    using PreciseMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 private constant BALANCE = 'Balance';
    bytes32 private constant WITHDRAWN = 'Withdrawn';
    bytes32[] private ESCROW_CONTRACTS = [
        CONTRACT_SUPPLY_SCHEDULE,
        CONTRACT_SPECIAL
    ];

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_ESCROW);
        imports = [
            CONTRACT_SYNTHX,
            CONTRACT_SYNTHX_TOKEN,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_SPECIAL
        ];
    }

    function Storage() internal view returns (IEscrowStorage) {
        return IEscrowStorage(getStorage());
    }

    function deposit(
        uint256 period,
        address account,
        uint256 amount
    ) external containAddressOrOwner(ESCROW_CONTRACTS) {
        Storage().incrementUint(BALANCE, account, amount);
        Storage().setEscrow(account, period, amount);
    }

    function withdraw(address account, uint256 amount) external onlyAddress(CONTRACT_SYNTHX) {
        uint256 withdrawable = getWithdrawable(account);
        withdrawable.sub(amount, 'Escrow: withdraw amount exceeds withdrawable');
        Storage().decrementUint(BALANCE, account, amount, 'Escrow: withdraw amount exceeds balance');

        Storage().incrementUint(WITHDRAWN, account, amount);
        IERC20(requireAddress(CONTRACT_SYNTHX_TOKEN)).safeTransfer(account, amount);
    }

    function getWithdrawable(address account) public view returns (uint256) {
        uint256 currentPeriod = SupplySchedule().currentPeriod();
        uint256 withdrawn = Storage().getUint(WITHDRAWN, account);
        uint256 available = getBalance(account);
        uint256 withdrawable = 0;
        for (uint256 i = 0; i < currentPeriod; i++) {
            uint256 amount = Storage().getEscrow(account, i);
            withdrawable = withdrawable.add(amount);
        }
        if (withdrawable <= withdrawn) return 0;
        return withdrawable.sub(withdrawn).min(available);
    }

    function getBalance(address account) public view returns (uint256) {
        return Storage().getUint(BALANCE, account);
    }
}
