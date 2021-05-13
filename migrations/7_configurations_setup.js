const Web3Utils = require('web3-utils');
const {liquidationDelay, mintPeriodDuration} = require('./config');

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
            return contracts.setting.setLiquidationDelay(liquidationDelay);
        })
        .then(receipt => {
            console.log('setting.setLiquidationDelay receipt: ', receipt);
            return contracts.setting.setMintPeriodDuration(mintPeriodDuration);
        })

        // setup BTC
        .then((receipt) => {
            console.log('setting.setMintPeriodDuration receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_BTC, Web3Utils.toWei('3', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(BTC) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_BTC, Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(BTC) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_BTC, Web3Utils.toWei('2', 'milliether'));
        })

        // setup ETH
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(BTC) receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_ETH, Web3Utils.toWei('3', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(ETH) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_ETH, Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(ETH) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_ETH, Web3Utils.toWei('2', 'milliether'));
        })

        // setup BNB
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(ETH) receipts: ', receipt);
            return contracts.setting.setCollateralRate(ASSET_BNB, Web3Utils.toWei('3', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(BNB) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(ASSET_BNB, Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(BNB) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(ASSET_BNB, Web3Utils.toWei('2', 'milliether'));
        })
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(BNB) receipts: ', receipt);
        });
}
