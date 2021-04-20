// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeERC20.sol';
import './base/Rewards.sol';
import './interfaces/IProvider.sol';
import './interfaces/storages/IProviderStorage.sol';
import './interfaces/IEscrow.sol';

contract Provider is Rewards, IProvider {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_PROVIDER);
        imports = [CONTRACT_SYNBIT, CONTRACT_SUPPLY_SCHEDULE, CONTRACT_ESCROW];
    }

    function Storage() private view returns (IProviderStorage) {
        return IProviderStorage(getStorage());
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
    }

    function lock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Storage().incrementLocked(asset, account, getCurrentPeriod(), amount);
    }

    function unlock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Storage().decrementLocked(asset, account, getCurrentPeriod(), amount, 'Provider: unlock amount exceeds locked');
    }

    function getLocked(bytes32 asset, address account) external view returns (uint256) {
        return Storage().getLocked(asset, account, getCurrentPeriod());
    }

    function getTotalLocked(bytes32 asset) external view returns (uint256) {
        return Storage().getLocked(asset, address(0), getCurrentPeriod());
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
        require(claimable > 0, 'Provider: claimable is zero');

        uint256 claimablePeriod = getClaimablePeriod();
        setClaimed(asset, account, claimablePeriod, claimable);

        vestTime = Escrow().deposit(claimablePeriod, account, claimable);
        return (claimablePeriod, claimable, vestTime);
    }

    function getClaimable(bytes32 asset, address account) public view returns (uint256) {
        uint256 rewardPercentage = getRewardPercentage(asset);
        require(rewardPercentage > 0, 'Provider: asset not supported');

        uint256 rewards = getRewardSupply(CONTRACT_PROVIDER);
        if (rewards == 0) return 0;

        uint256 claimablePeriod = getClaimablePeriod();
        if (getClaimed(asset, account, claimablePeriod) > 0) return 0;

        uint256 totalLocked = Storage().getLocked(asset, address(0), claimablePeriod);
        uint256 accountLocked = Storage().getLocked(asset, account, claimablePeriod);
        uint256 percentage = accountLocked.decimalDivide(totalLocked);
        return rewards.decimalMultiply(rewardPercentage).decimalMultiply(percentage);
    }
}
