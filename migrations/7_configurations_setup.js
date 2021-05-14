const Web3Utils = require('web3-utils');
const config = require('./config');

const contractAddrs = require('../finalContractAddrs.json');

const Setting = artifacts.require("Setting");

const ASSET_ETH = Web3Utils.fromAscii('ETH');
const ASSET_BTC = Web3Utils.fromAscii('BTC');
const ASSET_BNB = Web3Utils.fromAscii('BNB');

module.exports = async function(deployer) {
    let contracts = {};

    contracts.setting = await Setting.at(contractAddrs.setting);

    await deployer
        .then(() => {
            return contracts.setting.setLiquidationDelay(config.LiquidationDelay);
        })
        .then(receipt => {
            console.log('setting.setLiquidationDelay receipt: ', receipt);
            return contracts.setting.setMintPeriodDuration(config.MintPeriodDuration);
        })

        // setup BTC
        .then((receipt) => {
            console.log('setting.setMintPeriodDuration receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_BTC, config.CollateralRateBTC);
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(BTC) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_BTC, config.LiquidationRateBTC);
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(BTC) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_BTC, config.TradingFeeRateBTC);
        })

        // setup ETH
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(BTC) receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_ETH, config.CollateralRateETH);
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(ETH) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_ETH, config.LiquidationRateETH);
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(ETH) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_ETH, config.TradingFeeRateETH);
        })

        // setup BNB
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(ETH) receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_BNB, config.CollateralRateBNB);
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(BNB) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_BNB, config.LiquidationRateETH);
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(BNB) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_BNB, config.TradingFeeRateBNB);
        })
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(BNB) receipts: ', receipt);
        });
}
