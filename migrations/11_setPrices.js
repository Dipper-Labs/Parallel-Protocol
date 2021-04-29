const fs = require('fs');
const Web3Utils = require('web3-utils');
const Oracle = artifacts.require("SynthxOracle");
const prices = require('../prices.json')

const oracleAddress = '0xc8FcD5912E6eb90255e26D88339C246a7C4f9AbC';

const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const btcPriceKey = Web3Utils.fromAscii('BTC');
const dipPriceKey = Web3Utils.fromAscii('DIP');

module.exports = async function(deployer, network, accounts) {
    const oracle = await Oracle.at(oracleAddress);

    await deployer
        .then(() => {
            return oracle.setPrice(ethPriceKey, Web3Utils.toWei(prices.ethereum.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log(receipt);
            return oracle.setPrice(bnbPriceKey, Web3Utils.toWei(prices.binancecoin.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log(receipt);
            return oracle.setPrice(btcPriceKey, Web3Utils.toWei(prices.bitcoin.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log(receipt);
            return oracle.setPrice(dipPriceKey, Web3Utils.toWei(prices['dipper-network'].usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log(receipt);
            return oracle.getPrice(ethPriceKey)
        })
        .then(res => {
            console.log(res.price.toString());
            return oracle.getPrice(bnbPriceKey)
        })
        .then(res => {
            console.log(res.price.toString());
            return oracle.getPrice(btcPriceKey)
        })
        .then(res => {
            console.log(res.price.toString());
            return oracle.getPrice(dipPriceKey)
        })
        .then(res => {
            console.log(res.price.toString());
        })
}