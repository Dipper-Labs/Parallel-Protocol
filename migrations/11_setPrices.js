const fs = require('fs');
const Web3Utils = require('web3-utils');
const Oracle = artifacts.require("SynthxOracle");
const tokens_price = require('../tokens_price.json')
const stocks_price = require('../stocks_price.json')

const oracleAddress = '0xc8FcD5912E6eb90255e26D88339C246a7C4f9AbC';

const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const btcPriceKey = Web3Utils.fromAscii('BTC');
const dipPriceKey = Web3Utils.fromAscii('DIP');
const dTslaPriceKey = Web3Utils.fromAscii('dTSLA');
const dApplePriceKey = Web3Utils.fromAscii('dAPPLE');

module.exports = async function(deployer, network, accounts) {
    const oracle = await Oracle.at(oracleAddress);

    await deployer
        .then(() => {
            return oracle.setPrice(ethPriceKey, Web3Utils.toWei(tokens_price.ethereum.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[ETH] receipt: ', receipt);
            return oracle.setPrice(bnbPriceKey, Web3Utils.toWei(tokens_price.binancecoin.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[BNB] receipt: ', receipt);
            return oracle.setPrice(btcPriceKey, Web3Utils.toWei(tokens_price.bitcoin.usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[BTC] receipt: ', receipt);
            return oracle.setPrice(dipPriceKey, Web3Utils.toWei(tokens_price['dipper-network'].usd.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[DIP] receipt: ', receipt);
            return oracle.setPrice(dTslaPriceKey, Web3Utils.toWei(stocks_price.tsla.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[TSLA] receipt: ', receipt);
            return oracle.setPrice(dApplePriceKey, Web3Utils.toWei(stocks_price.aapl.toString(), 'ether'))
        })
        .then(receipt => {
            console.log('setPrice[AAPL] receipt: ', receipt);
            return oracle.getPrice(ethPriceKey)
        })
        .then(res => {
            console.log('price[ETH] :', Web3Utils.fromWei(res.price).toString());
            return oracle.getPrice(bnbPriceKey)
        })
        .then(res => {
            console.log('price[BNB] :', Web3Utils.fromWei(res.price).toString());
            return oracle.getPrice(btcPriceKey)
        })
        .then(res => {
            console.log('price[BTC] :', Web3Utils.fromWei(res.price).toString());
            return oracle.getPrice(dipPriceKey)
        })
        .then(res => {
            console.log('price[DIP] :', Web3Utils.fromWei(res.price).toString());
            return oracle.getPrice(dTslaPriceKey)
        })
        .then(res => {
            console.log('price[TSLA] :', Web3Utils.fromWei(res.price).toString());
            return oracle.getPrice(dApplePriceKey)
        })
        .then(res => {
            console.log('price[AAPL] :', Web3Utils.fromWei(res.price).toString());
        })
}