// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Rewards.sol';
import './interfaces/ISpecial.sol';
import './interfaces/storages/IStakerStorage.sol';
import './interfaces/IIssuer.sol';
import './interfaces/ISetting.sol';
import './interfaces/IEscrow.sol';
import './interfaces/IStaker.sol';

contract Special is Rewards, ISpecial {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_SPECIAL);
        imports = [
            CONTRACT_SYNBIT,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ISSUER,
            CONTRACT_SETTING,
            CONTRACT_ESCROW,
            CONTRACT_STAKER
        ];
    }

    function Issuer() private view returns (IIssuer) {
        return IIssuer(requireAddress(CONTRACT_ISSUER));
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
    }

    function Staker() private view returns (IStaker) {
        return IStaker(requireAddress(CONTRACT_STAKER));
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
        require(claimable > 0, 'Special: claimable is zero');

        uint256 claimablePeriod = getClaimablePeriod();
        setClaimed(asset, account, claimablePeriod, claimable);

        vestTime = Escrow().deposit(claimablePeriod, account, claimable);
        return (claimablePeriod, claimable, vestTime);
    }

    function getClaimable(bytes32 asset, address account) public view returns (uint256) {
        require(asset == SYN, 'Special: only supports SYN');

        uint256 rewards = getRewardSupply(CONTRACT_SPECIAL);
        if (rewards == 0) return 0;

        uint256 claimablePeriod = getClaimablePeriod();
        if (getClaimed(asset, account, claimablePeriod) > 0) return 0;

        uint256 collateralRate = Staker().getCollateralRate(SYN, account);
        if (collateralRate < Setting().getCollateralRate(SYN)) return 0;

        uint256 accountPercentage = Issuer().getDebtPercentage(SYN, account, claimablePeriod);
        uint256 stakePercentage = Issuer().getDebtPercentage(SYN, address(0), claimablePeriod);
        uint256 percentage = accountPercentage.preciseDivide(stakePercentage);

        return rewards.decimalMultiply(percentage.toDecimal());
    }
}
