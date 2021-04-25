const fs = require('fs');
const Web3Utils = require('web3-utils');

const Resolver = artifacts.require("Resolver");
const AssetPrice = artifacts.require("AssetPrice");

module.exports = async function(deployer, network, accounts) {
    let contractsAddrs = {};

    const data = fs.readFileSync('contractsAddrs.json', 'utf-8')
    contractsAddrs = JSON.parse(data.toString());

    let contracts = {};
    contracts.resolver = await Resolver.at(contractsAddrs.resolver);
    contracts.assetPrice = await AssetPrice.at('0x644a589DeBd2603912Aaf7b79EF73845E3bf55a4')

    await deployer
        .then(() => {
            return contracts.resolver.getAddress(Web3Utils.fromAscii('AssetPrice'));
        })
        .then(async (AssetPriceAddr) => {
            console.log('asset price addr: ', AssetPriceAddr);
            return;
        })
        .then(() => {
            return contracts.assetPrice.setMaxDelayTime(360000);
        })
        .then((receipt) => {
            console.log('receipt: ', receipt);
            return contracts.assetPrice.maxDelayTime();
        })
        .then((maxDelayTime) => {
            console.log("maxDelayTime: ", maxDelayTime);
        })
}