const Web3Utils = require('web3-utils');

const SynthxOracle = artifacts.require("SynthxOracle");

const tokens_price = require('../tokens_price.json');
const stocks_price = require('../stocks_price.json');
const contractAddrs = require('../finalContractAddrs.json');

const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const btcPriceKey = Web3Utils.fromAscii('BTC');
const dipPriceKey = Web3Utils.fromAscii('DIP');
const dTSLAPriceKey = Web3Utils.fromAscii('dTSLA');
const dAAPLPriceKey = Web3Utils.fromAscii('dAAPL');

module.exports = async function(deployer, network, accounts) {
    const synthxOracle = await SynthxOracle.at(contractAddrs.synthxOracle);

    if (network == "bsc") {
        // for DIP only, BTC ETH BNB APPL TSLA will get from chainlinkOracle
        await deployer
            .then(() => {
                return synthxOracle.setPrice(dipPriceKey, Web3Utils.toWei(tokens_price['dipper-network'].usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[DIP] receipt: ', receipt);
            });

    } else if (network == "bsctestnet") {
        // for DIP APPL TSLA only, BTC ETH BNB will get from chainlinkOracle
        await deployer
            .then(() => {
                return synthxOracle.setPrice(dipPriceKey, Web3Utils.toWei(tokens_price['dipper-network'].usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[DIP] receipt: ', receipt);
                return synthxOracle.setPrice(dTSLAPriceKey, Web3Utils.toWei(stocks_price.tsla.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[dTSLA] receipt: ', receipt);
                return synthxOracle.setPrice(dAAPLPriceKey, Web3Utils.toWei(stocks_price.aapl.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[dAAPL] receipt: ', receipt);
            })
    } else { // local test...
        // for DIP APPL TSLA BTC ETH BNB
        await deployer
            .then(() => {
                return synthxOracle.setPrice(ethPriceKey, Web3Utils.toWei(tokens_price.ethereum.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[ETH] receipt: ', receipt);
                return synthxOracle.setPrice(bnbPriceKey, Web3Utils.toWei(tokens_price.binancecoin.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[BNB] receipt: ', receipt);
                return synthxOracle.setPrice(btcPriceKey, Web3Utils.toWei(tokens_price.bitcoin.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[BTC] receipt: ', receipt);
                return synthxOracle.setPrice(dipPriceKey, Web3Utils.toWei(tokens_price['dipper-network'].usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[DIP] receipt: ', receipt);
                return synthxOracle.setPrice(dTSLAPriceKey, Web3Utils.toWei(stocks_price.tsla.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[dTSLA] receipt: ', receipt);
                return synthxOracle.setPrice(dAAPLPriceKey, Web3Utils.toWei(stocks_price.aapl.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[dAAPL] receipt: ', receipt);
            });
    }
}