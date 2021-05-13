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

    const assetName = "dTSLA";

    await deployer
        .then(() => {
            console.log('TODO...');
        });
}