const fs = require('fs');
const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json');

const Setting = artifacts.require("Setting");
const Resolver = artifacts.require("Resolver");
const AssetPrice = artifacts.require("AssetPrice");
const Oracle = artifacts.require("SynthxOracle");

// must setup before run script
const assetName = 'BNB';
const assetNameKey = Web3Utils.fromAscii(assetName);
const assetERC20Addr = '';
const oracleType = 'SynthxOracle'; // ['SynthxOracle', 'ChainLinkOracle']
const synthName = 'dTSET'; // erc20 Name, string type
const synthSymbol = 'dTEST'; // erc20 symbol, string type
const synth = Web3Utils.fromAscii('dTEST'); // eg: dUSD, dTSLA, dAAPL
const synthPriceKey = Web3Utils.fromAscii('dTEST'); // eg BTC ETH BTC dAAPL dTSLA
const currentPrice = Web3Utils.toWei('0.0052836', 'ether'); // only for SynthxOracle, in USD
const chainLinkPriceContractAddr = ""; // only for ChainLinkOracle, for BSC chain query from https://docs.chain.link/docs/binance-smart-chain-addresses/


module.exports = async function(deployer, network, accounts) {
    let contracts = {};

    contracts.assetPrice = await AssetPrice.at(contractAddrs.assetPrice);
    contracts.resolver = await Resolver.at(contractAddrs.resolver);
    contracts.setting = await Setting.at(contractAddrs.setting);
    if (oracleType === 'ChainLinkOracle') {
        contracts.oracle = await ChainLinkOracle.at(contractAddrs.chainLinkOracle);
    } else {
        contracts.oracle = await SynthxOracle.at(contractAddrs.synthxOracle);
    }

    await deployer
        .then(() => {
            return contracts.assetPrice.setOracle(assetNameKey, contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Stake'), assetNameKey, assetERC20Addr);
        })
        .then((receipt) => {
            console.log('resolver.addAsset receipts: ', receipt);
            return contracts.setting.setCollateralRate(assetNameKey, Web3Utils.toWei('3', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(ETH) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(assetNameKey, Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(ETH) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(assetNameKey, Web3Utils.toWei('2', 'milliether'));
        })
        .then(() => {
            return contracts.oracle.setPrice(assetNameKey, Web3Utils.toWei('3000', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(ETH) receipts: ', receipt);
        });
}