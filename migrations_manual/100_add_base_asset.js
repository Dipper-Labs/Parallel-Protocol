const fs = require('fs');
const Web3Utils = require('web3-utils');

const Setting = artifacts.require("Setting");
const Resolver = artifacts.require("Resolver");
const AssetPrice = artifacts.require("AssetPrice");
const Oracle = artifacts.require("SynthxOracle");

module.exports = async function(deployer, network, accounts) {
    let contractsAddrs = {};

    const data = fs.readFileSync('contractsAddrs.json', 'utf-8')
    contractsAddrs = JSON.parse(data.toString());

    console.log(contractsAddrs);

    let contracts = {};
    contracts.oracle = await Oracle.at(contractsAddrs.oracle);
    contracts.assetPrice = await AssetPrice.at(contractsAddrs.assetPrice);
    contracts.resolver = await Resolver.at(contractsAddrs.resolver);
    contracts.setting = await Setting.at(contractsAddrs.setting);

    console.log(contracts.oracle.address);
    console.log(contracts.assetPrice.address);
    console.log(contracts.resolver.address);
    console.log(contracts.setting.address);

    const assetName = "ETH";

    await deployer
        .then(() => {
            return contracts.oracle.setPrice(Web3Utils.fromAscii(assetName), Web3Utils.toWei('3000', 'ether'));
        })
        .then((receipt) => {
            console.log('oracle.setPrice(ETH) receipts: ', receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii(assetName), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle(ETH) receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii(assetName), "0x84b9b910527ad5c03a9ca831909e21e236ea7b06");
        })
        .then((receipt) => {
            console.log('resolver.addAsset(ETH) receipts: ', receipt);
            return contracts.setting.setCollateralRate(Web3Utils.fromAscii(assetName), Web3Utils.toWei('3', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate(ETH) receipts: ', receipt);
            return contracts.setting.setLiquidationRate(Web3Utils.fromAscii(assetName), Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('resolver.setLiquidationRate(ETH) receipts: ', receipt);
            return contracts.setting.setTradingFeeRate(Web3Utils.fromAscii(assetName), Web3Utils.toWei('2', 'milliether'));
        })
        .then((receipt) => {
            console.log('setting.setTradingFeeRate(ETH) receipts: ', receipt);
        });
}