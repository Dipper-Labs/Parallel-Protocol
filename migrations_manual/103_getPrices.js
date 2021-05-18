const Web3Utils = require('web3-utils');

const AssetPrice = artifacts.require("AssetPrice");

const contractAddrs = require('../finalContractAddrs.json');

const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const btcPriceKey = Web3Utils.fromAscii('BTC');
const dipPriceKey = Web3Utils.fromAscii('DIP');
const dTSLAPriceKey = Web3Utils.fromAscii('dTSLA');
const dAAPLPriceKey = Web3Utils.fromAscii('dAAPL');

module.exports = async function(deployer, network, accounts) {
    const assetPrice = await AssetPrice.at(contractAddrs.assetPrice);

    await deployer
        .then(() => {
            return assetPrice.getPriceFromOracle(dipPriceKey);
        })
        .then(price => {
            console.log('price[dip]: ', price.price.toString());
            return assetPrice.getPriceFromOracle(btcPriceKey);
        })
        .then(price => {
            console.log('price[btc]: ', price.price.toString());
            return assetPrice.getPriceFromOracle(ethPriceKey);
        })
        .then(price => {
            console.log('price[eth]: ', price.price.toString());
            return assetPrice.getPriceFromOracle(bnbPriceKey);
        })
        .then(price => {
            console.log('price[bnb]: ', price.price.toString());
            return assetPrice.getPriceFromOracle(dAAPLPriceKey);
        })
        .then(price => {
            console.log('price[dAAPL]: ', price.price.toString());
            return assetPrice.getPriceFromOracle(dTSLAPriceKey);
        })
        .then(price => {
            console.log('price[dTSLA]: ', price.price.toString());
        });
}