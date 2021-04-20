// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/Paging.sol';
import './base/Importable.sol';
import './base/ExternalStorable.sol';
import './interfaces/ILiquidator.sol';
import './interfaces/storages/ILiquidatorStorage.sol';
import './interfaces/IIssuer.sol';
import './interfaces/ISetting.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/IStaker.sol';

contract Liquidator is Importable, ExternalStorable, ILiquidator {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_LIQUIDATOR);
        imports = [
            CONTRACT_SYNBIT,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ISSUER,
            CONTRACT_SETTING,
            CONTRACT_ASSET_PRICE,
            CONTRACT_STAKER
        ];
    }

    function Storage() internal view returns (ILiquidatorStorage) {
        return ILiquidatorStorage(getStorage());
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

    function Staker() private view returns (IStaker) {
        return IStaker(requireAddress(CONTRACT_STAKER));
    }

    function watchAccount(bytes32 stake, address account) external {
        uint256 currentCollateralRate = Staker().getCollateralRate(stake, account);
        uint256 liquidationCollateralRate = Setting().getLiquidationRate(stake);
        uint256 deadline = now.add(Setting().getLiquidationDelay());
        if (currentCollateralRate > liquidationCollateralRate) {
            Storage().removeWatch(stake, account);
        } else {
            Storage().addWatch(stake, account, deadline);
        }
    }

    function canLiquidate(bytes32 stake, address account) public view returns (bool) {
        uint256 deadline = Storage().getDeadline(stake, account);
        if (deadline == 0) return false;
        if (deadline > now) return false;
        uint256 currentCollateralRate = Staker().getCollateralRate(stake, account);
        uint256 liquidationCollateralRate = Setting().getLiquidationRate(stake);
        return (currentCollateralRate <= liquidationCollateralRate);
    }

    function getLiquidable(bytes32 stake, address account) external view returns (uint256) {
        if (!canLiquidate(stake, account)) return 0;

        uint256 debt = Issuer().getDebt(stake, account);
        uint256 collateralRate = Setting().getCollateralRate(stake);
        uint256 price = AssetPrice().getPrice(stake);
        uint256 currentStakeValue = Staker().getStaked(stake, account).decimalMultiply(price);
        uint256 minStakeValue = debt.decimalMultiply(collateralRate);
        if (currentStakeValue >= minStakeValue) return 0;

        uint256 liquidationFeeRate = Setting().getLiquidationFeeRate(stake);
        uint256 liquidable =
            minStakeValue.sub(currentStakeValue).decimalDivide(
                collateralRate.sub(PreciseMath.DECIMAL_ONE()).sub(liquidationFeeRate)
            );
        if (liquidable > debt)
            liquidable = currentStakeValue.decimalDivide(PreciseMath.DECIMAL_ONE().add(liquidationFeeRate));

        return liquidable;
    }

    function getUnstakable(bytes32 stake, uint256 amount) external view returns (uint256) {
        uint256 liquidationFeeRate = Setting().getLiquidationFeeRate(stake);
        uint256 price = AssetPrice().getPrice(stake);
        return amount.decimalMultiply(PreciseMath.DECIMAL_ONE().add(liquidationFeeRate)).decimalDivide(price);
    }

    function getAccounts(
        bytes32 stake,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getAccounts(stake, pageSize, pageNumber);
    }
}
