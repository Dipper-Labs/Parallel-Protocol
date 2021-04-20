pragma solidity ^0.5.17;

import '../lib/SafeMath.sol';
import '../lib/PreciseMath.sol';
import './Importable.sol';
import './ExternalStorable.sol';
import '../interfaces/IRewards.sol';
import '../interfaces/storages/IRewardsStorage.sol';

contract Rewards is Importable, ExternalStorable, IRewards {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    bytes32 private constant TOTAL = 'Total';

    function RewardsStorage() internal view returns (IRewardsStorage) {
        return IRewardsStorage(getStorage());
    }

    function setClaimed(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) internal {
        RewardsStorage().setClaimed(asset, account, period, amount);
    }

    function getClaimed(
        bytes32 asset,
        address account,
        uint256 period
    ) public view returns (uint256) {
        return RewardsStorage().getClaimed(asset, account, period);
    }

    function getClaimablePeriod() internal view returns (uint256) {
        uint256 period = SupplySchedule().lastMintPeriod();
        return (period == 0) ? period : period.sub(1);
    }

    function getRewardSupply(bytes32 recipient) internal view returns (uint256) {
        if (now > SupplySchedule().nextMintTime()) return 0;

        uint256 period = getClaimablePeriod();
        return SupplySchedule().mintableSupply(recipient, period);
    }

    function setRewardPercentage(bytes32 asset, uint256 percentage) external onlyOwner {
        uint256 totalPercentage = RewardsStorage().getRewardPercentage(TOTAL);
        uint256 previousPercentage = RewardsStorage().getRewardPercentage(asset);
        uint256 newTotalPercentage = totalPercentage.sub(previousPercentage).add(percentage);

        require(newTotalPercentage <= PreciseMath.DECIMAL_ONE(), 'Rewards: total percent must be no greater than 100%');
        RewardsStorage().setRewardPercentage(asset, percentage);
        RewardsStorage().setRewardPercentage(TOTAL, newTotalPercentage);
        emit RewardPercentageChanged(asset, previousPercentage, percentage);
    }

    function getRewardPercentage(bytes32 asset) public view returns (uint256) {
        return RewardsStorage().getRewardPercentage(asset);
    }
}
