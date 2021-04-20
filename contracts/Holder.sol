// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeERC20.sol';
import './base/Rewards.sol';
import './interfaces/IHolder.sol';
import './interfaces/storages/IHolderStorage.sol';
import './interfaces/ILockable.sol';
import './interfaces/IERC20.sol';

contract Holder is Rewards, IHolder {
    using SafeERC20 for IERC20;

    address public constant LOCK_ADDRESS = 0x010C10C10C10C10c10c10C10c10C10c10c10C10c;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_HOLDER);
        imports = [CONTRACT_SYNBIT, CONTRACT_SUPPLY_SCHEDULE, CONTRACT_SYNBIT_TOKEN];
    }

    function Storage() private view returns (IHolderStorage) {
        return IHolderStorage(getStorage());
    }

    function Lockable(bytes32 asset) private view returns (ILockable) {
        return ILockable(requireAsset('Hold', asset));
    }

    function lock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Lockable(asset).lock(account, amount);
        _setLocked(asset, account);
    }

    function unlock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Lockable(asset).unlock(account, amount);
        _setLocked(asset, account);
    }

    function _setLocked(bytes32 asset, address account) private {
        ILockable token = Lockable(asset);
        Storage().setLocked(asset, account, getCurrentPeriod(), token.getLocked(account), token.getTotalLocked());
    }

    function getLocked(bytes32 asset, address account) external view returns (uint256) {
        return Lockable(asset).getLocked(account);
    }

    function getTotalLocked(bytes32 asset) external view returns (uint256) {
        return Lockable(asset).getTotalLocked();
    }

    function getPeriodLocked(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256) {
        return Storage().getLocked(asset, account, period);
    }

    function claim(bytes32 asset, address account)
        external
        onlyAddress(CONTRACT_SYNBIT)
        returns (
            uint256 period,
            uint256 amount,
            uint256 vestTime
        )
    {
        uint256 claimable = getClaimable(asset, account);
        require(claimable > 0, 'Holder: claimable is zero');

        uint256 claimablePeriod = getClaimablePeriod();
        setClaimed(asset, account, claimablePeriod, claimable);

        IERC20(requireAddress(CONTRACT_SYNBIT_TOKEN)).safeTransfer(account, claimable);
        return (claimablePeriod, claimable, 0);
    }

    function getClaimable(bytes32 asset, address account) public view returns (uint256) {
        uint256 rewardPercentage = getRewardPercentage(asset);
        require(rewardPercentage > 0, 'Holder: only supports lockable asset');

        uint256 rewards = getRewardSupply(CONTRACT_HOLDER);
        if (rewards == 0) return 0;

        uint256 claimablePeriod = getClaimablePeriod();
        if (getClaimed(asset, account, claimablePeriod) > 0) return 0;

        uint256 totalLocked = Storage().getLocked(asset, address(0), claimablePeriod);
        uint256 accountLocked = Storage().getLocked(asset, account, claimablePeriod);
        uint256 percentage = accountLocked.decimalDivide(totalLocked);
        return rewards.decimalMultiply(rewardPercentage).decimalMultiply(percentage);
    }
}
