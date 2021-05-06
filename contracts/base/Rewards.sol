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
        address account,
        uint256 period,
        uint256 amount
    ) internal {
        RewardsStorage().setClaimed(account, period, amount);
    }

    function getClaimed(
        address account,
        uint256 period
    ) public view returns (uint256) {
        return RewardsStorage().getClaimed(account, period);
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
}
