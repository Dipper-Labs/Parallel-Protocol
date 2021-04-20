// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/ExternalStorable.sol';
import './interfaces/ISetting.sol';
import './interfaces/storages/ISettingStorage.sol';

contract Setting is ExternalStorable, ISetting {
    bytes32 private constant COLLATERAL_RATE = 'CollateralRate';
    bytes32 private constant LIQUIDATION_RATE = 'LiquidationRate';
    bytes32 private constant LIQUIDATION_FEE_RATE = 'LiquidationFeeRate';
    bytes32 private constant LIQUIDATION_DELAY = 'LiquidationDelay';
    bytes32 private constant TRADING_FEE_RATE = 'TradingFeeRate';
    bytes32 private constant MIN_STAKE_TIME = 'MinStakeTime';
    bytes32 private constant MINT_PERIOD_DURATION = 'MintPeriodDuration';

    constructor() public {
        setContractName(CONTRACT_SETTING);
    }

    function Storage() private view returns (ISettingStorage) {
        return ISettingStorage(getStorage());
    }

    function setCollateralRate(bytes32 asset, uint256 rate) external onlyOwner {
        emit SettingChanged(COLLATERAL_RATE, asset, Storage().getUint(COLLATERAL_RATE, asset), rate);
        Storage().setUint(COLLATERAL_RATE, asset, rate);
    }

    function getCollateralRate(bytes32 asset) external view returns (uint256) {
        return Storage().getUint(COLLATERAL_RATE, asset);
    }

    function setLiquidationRate(bytes32 asset, uint256 rate) external onlyOwner {
        emit SettingChanged(LIQUIDATION_RATE, asset, Storage().getUint(LIQUIDATION_RATE, asset), rate);
        Storage().setUint(LIQUIDATION_RATE, asset, rate);
    }

    function getLiquidationRate(bytes32 asset) external view returns (uint256) {
        return Storage().getUint(LIQUIDATION_RATE, asset);
    }

    function setLiquidationFeeRate(bytes32 asset, uint256 rate) external onlyOwner {
        emit SettingChanged(LIQUIDATION_FEE_RATE, asset, Storage().getUint(LIQUIDATION_FEE_RATE, asset), rate);
        Storage().setUint(LIQUIDATION_FEE_RATE, asset, rate);
    }

    function getLiquidationFeeRate(bytes32 asset) external view returns (uint256) {
        return Storage().getUint(LIQUIDATION_FEE_RATE, asset);
    }

    function setLiquidationDelay(uint256 delay) external onlyOwner {
        emit SettingChanged(LIQUIDATION_DELAY, bytes32(0), Storage().getUint(LIQUIDATION_DELAY), delay);
        Storage().setUint(LIQUIDATION_DELAY, delay);
    }

    function getLiquidationDelay() external view returns (uint256) {
        return Storage().getUint(LIQUIDATION_DELAY);
    }

    function setTradingFeeRate(bytes32 asset, uint256 rate) external onlyOwner {
        emit SettingChanged(TRADING_FEE_RATE, asset, Storage().getUint(TRADING_FEE_RATE, asset), rate);
        Storage().setUint(TRADING_FEE_RATE, asset, rate);
    }

    function getTradingFeeRate(bytes32 asset) external view returns (uint256) {
        return Storage().getUint(TRADING_FEE_RATE, asset);
    }

    function setMinStakeTime(uint256 time) external onlyOwner {
        emit SettingChanged(MIN_STAKE_TIME, bytes32(0), Storage().getUint(MIN_STAKE_TIME), time);
        Storage().setUint(MIN_STAKE_TIME, time);
    }

    function getMinStakeTime() external view returns (uint256) {
        return Storage().getUint(MIN_STAKE_TIME);
    }

    function setMintPeriodDuration(uint256 time) external onlyOwner {
        emit SettingChanged(MINT_PERIOD_DURATION, bytes32(0), Storage().getUint(MINT_PERIOD_DURATION), time);
        Storage().setUint(MINT_PERIOD_DURATION, time);
    }

    function getMintPeriodDuration() external view returns (uint256) {
        return Storage().getUint(MINT_PERIOD_DURATION);
    }
}
