// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Rewards.sol';
import './interfaces/IStaker.sol';
import './interfaces/storages/IStakerStorage.sol';
import './interfaces/IIssuer.sol';
import './interfaces/ISetting.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/IEscrow.sol';
import './interfaces/ITrader.sol';

contract Staker is Rewards, IStaker {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_STAKER);
        imports = [
            CONTRACT_SYNBIT,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ISSUER,
            CONTRACT_SETTING,
            CONTRACT_ASSET_PRICE,
            CONTRACT_ESCROW,
            CONTRACT_TRADER
        ];
    }

    function Storage() private view returns (IStakerStorage) {
        return IStakerStorage(getStorage());
    }

    function Issuer() private view returns (IIssuer) {
        return IIssuer(requireAddress(CONTRACT_ISSUER));
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function AssetPrice() private view returns (IAssetPrice) {
        return IAssetPrice(requireAddress(CONTRACT_ASSET_PRICE));
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
    }

    function Trader() private view returns (ITrader) {
        return ITrader(requireAddress(CONTRACT_TRADER));
    }

    function stake(
        bytes32 token,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Storage().incrementStaked(token, account, amount);
    }

    function unstake(
        bytes32 token,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        Storage().decrementStaked(token, account, amount, 'Staker: unstake amount exceeds staked');
    }

    function getStaked(bytes32 token, address account) public view returns (uint256) {
        uint256 staked = Storage().getStaked(token, account);
        if (token == SYN) staked = staked.add(Escrow().getStaked(account));
        return staked;
    }

    function getTransferable(bytes32 token, address account) external view returns (uint256 staker, uint256 escrow) {
        uint256 debt = Issuer().getDebt(token, account);
        uint256 price = AssetPrice().getPrice(token);
        uint256 staked = getStaked(token, account);
        uint256 collateralRate = Setting().getCollateralRate(token);
        uint256 stakeAmount = debt.decimalMultiply(collateralRate).decimalDivide(price);
        if (stakeAmount >= staked) return (0, 0);

        uint256 transferable = staked.sub(stakeAmount);
        uint256 _staked = Storage().getStaked(token, account);
        if (transferable <= _staked) return (transferable, 0);

        return (_staked, transferable.sub(_staked));
    }

    function getCollateralRate(bytes32 token, address account) public view returns (uint256) {
        uint256 debt = Issuer().getDebt(token, account);
        uint256 price = AssetPrice().getPrice(token);
        uint256 staked = getStaked(token, account);
        return staked.decimalMultiply(price).decimalDivide(debt);
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
        require(claimable > 0, 'Staker: claimable is zero');

        uint256 claimablePeriod = getClaimablePeriod();
        setClaimed(asset, account, claimablePeriod, claimable);

        if (asset == USD) {
            Issuer().burnSynth(USD, Trader().FEE_ADDRESS(), claimable);
            Issuer().issueSynth(USD, account, claimable);
        } else {
            vestTime = Escrow().deposit(claimablePeriod, account, claimable);
        }

        return (claimablePeriod, claimable, vestTime);
    }

    function getClaimable(bytes32 asset, address account) public view returns (uint256) {
        require(asset == SYN || asset == USD, 'Staker: only supports SYN & yUSD');

        uint256 rewards = getRewardSupply(CONTRACT_STAKER);
        if (rewards == 0) return 0;

        uint256 claimablePeriod = getClaimablePeriod();
        if (getClaimed(asset, account, claimablePeriod) > 0) return 0;

        uint256 claimable = 0;

        if (asset == USD) {
            uint256 rewardPercentage = getRewardPercentage(asset);
            rewards = Trader().getTradingFee(address(0), claimablePeriod).decimalMultiply(rewardPercentage);
            if (rewards == 0) return 0;
        }

        bytes32[] memory stakes = assets('Stake');
        for (uint256 i = 0; i < stakes.length; i++) {
            uint256 collateralRate = getCollateralRate(stakes[i], account);
            if (collateralRate < Setting().getCollateralRate(stakes[i])) continue;

            uint256 percentage = Issuer().getDebtPercentage(stakes[i], account, claimablePeriod).toDecimal();
            claimable = claimable.add(rewards.decimalMultiply(percentage));
        }

        return claimable;
    }
}
