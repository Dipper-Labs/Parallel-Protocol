const fs = require('fs');
const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util')

const commonContractAddrs = require('../commonContractAddrs.json');
const bscPriceContracts = require('./bsc_price_contracts.json');
const bscTestnetPriceContracts = require('./bsctestnet_price_contracts.json');
const stocksPrice = require('../stocks_price.json');
const tokensPrice = require('../tokens_price.json');

const OracleStorage = artifacts.require("OracleStorage");
const SynthxOracle = artifacts.require("SynthxOracle");
const ChainLinkOracle = artifacts.require("ChainLinkOracle");
const AssetPrice = artifacts.require("AssetPrice");

const btcPriceKey = Web3Utils.fromAscii('BTC');
const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const dipPriceKey = Web3Utils.fromAscii('DIP');
const dAAPLPriceKey = Web3Utils.fromAscii('dAAPL');
const dTSLAPriceKey = Web3Utils.fromAscii('dTSLA');

const contractAddrsFile = 'contractAddrs.json';

module.exports = async function(deployer, network, accounts) {
    let contracts = {};

    contracts.assetPrice = await AssetPrice.at(commonContractAddrs.assetPrice);

    if (network == "bsc") {
        await deployer
            .then(() => {
                return deployer.deploy(ChainLinkOracle);
            })
            .then(chainLinkOracle => {
                checkUndefined(chainLinkOracle);
                contracts.chainLinkOracle = chainLinkOracle;
                commonContractAddrs.chainLinkOracle = contracts.chainLinkOracle.address;
                return contracts.chainLinkOracle.setAggregator(btcPriceKey, bscPriceContracts.BTC);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(BTC) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(ethPriceKey, bscPriceContracts.ETH);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(ETH) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(bnbPriceKey, bscPriceContracts.BNB);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(BNB) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(dAAPLPriceKey, bscPriceContracts.AAPL);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(AAPL) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(dTSLAPriceKey, bscPriceContracts.TSLA);
            })
            // assetPrice setOracles
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(AAPL) receipt: ', receipt);
                return contracts.assetPrice.setOracle(btcPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BTC) receipt: ', receipt);
                return contracts.assetPrice.setOracle(ethPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(ETH) receipt: ', receipt);
                return contracts.assetPrice.setOracle(bnbPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BNB) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dAAPLPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dAAPL) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dTSLAPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dTSLA) receipt: ', receipt);
                console.log("oracle contracts deployment finished\n\n");

                const addrs = JSON.stringify(commonContractAddrs, null, '\t');

                fs.writeFile(contractAddrsFile, addrs, (err) => {
                    if (err) {
                        throw err;
                    }
                    console.log("contractAddrs saved");
                    return true;
                });
            });
    } else if (network == "bsctestnet") {
        await deployer
            .then(function() {
                return deployer.deploy(SynthxOracle);
            })
            .then((synthxOracle) => {
                checkUndefined(synthxOracle);
                contracts.synthxOracle = synthxOracle;
                commonContractAddrs.synthxOracle = synthxOracle.address;
                return deployer.deploy(OracleStorage, synthxOracle.address);
            })
            .then((oracleStorage) => {
                checkUndefined(oracleStorage);
                return contracts.synthxOracle.setStorage(oracleStorage.address);
            })
            .then(receipt => {
                console.log('synthxOracle.setStorage receipt: ', receipt);
                return deployer.deploy(ChainLinkOracle);
            })
            .then(chainLinkOracle => {
                checkUndefined(chainLinkOracle);
                contracts.chainLinkOracle = chainLinkOracle;
                commonContractAddrs.chainLinkOracle = contracts.chainLinkOracle.address;
                return contracts.chainLinkOracle.setAggregator(btcPriceKey, bscTestnetPriceContracts.BTC);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(BTC) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(ethPriceKey, bscTestnetPriceContracts.ETH);
            })
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(ETH) receipt: ', receipt);
                return contracts.chainLinkOracle.setAggregator(bnbPriceKey, bscTestnetPriceContracts.BNB);
            })
            // assetPrice setOracles
            .then(receipt => {
                console.log('chainLinkOracle.setAggregator(BNB) receipt: ', receipt);
                return contracts.assetPrice.setOracle(btcPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BTC) receipt: ', receipt);
                return contracts.assetPrice.setOracle(ethPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(ETH) receipt: ', receipt);
                return contracts.assetPrice.setOracle(bnbPriceKey, contracts.chainLinkOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BNB) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dAAPLPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dAAPL) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dTSLAPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dTSLA) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dipPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(DIP) receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dipPriceKey, Web3Utils.toWei(tokensPrice['dipper-network'].usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('synthxOracle.setPrice[DIP] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dTSLAPriceKey, Web3Utils.toWei(stocksPrice.tsla.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('synthxOracle.setPrice[dTSLA] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dAAPLPriceKey, Web3Utils.toWei(stocksPrice.aapl.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('synthxOracle.setPrice[dAAPL] receipt: ', receipt);
                console.log("oracle contracts deployment finished\n\n");

                const addrs = JSON.stringify(commonContractAddrs, null, '\t');

                fs.writeFile(contractAddrsFile, addrs, (err) => {
                    if (err) {
                        throw err;
                    }
                    console.log("contractAddrs saved");
                    return true;
                });
            });
    } else {
        await deployer
            .then(() => {
                return deployer.deploy(SynthxOracle);
            })
            .then((synthxOracle) => {
                checkUndefined(synthxOracle);
                contracts.synthxOracle = synthxOracle;
                commonContractAddrs.synthxOracle = synthxOracle.address;
                return deployer.deploy(OracleStorage, synthxOracle.address);
            })
            .then((oracleStorage) => {
                checkUndefined(oracleStorage);
                return contracts.synthxOracle.setStorage(oracleStorage.address);
            })
            .then((receipt) => {
                console.log('oracle.setStorage receipts: ', receipt);
                return contracts.synthxOracle.setPrice(ethPriceKey, Web3Utils.toWei(tokensPrice.ethereum.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[ETH] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(bnbPriceKey, Web3Utils.toWei(tokensPrice.binancecoin.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[BNB] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(btcPriceKey, Web3Utils.toWei(tokensPrice.bitcoin.usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[BTC] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dipPriceKey, Web3Utils.toWei(tokensPrice['dipper-network'].usd.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[DIP] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dTSLAPriceKey, Web3Utils.toWei(stocksPrice.tsla.toString(), 'ether'))
            })
            .then(receipt => {
                console.log('setPrice[TSLA] receipt: ', receipt);
                return contracts.synthxOracle.setPrice(dAAPLPriceKey, Web3Utils.toWei(stocksPrice.aapl.toString(), 'ether'))
            })

            // assetPrice setOracles
            .then(receipt => {
                console.log('synthxOracle.setPrice[dAAPL] receipt: ', receipt);
                return contracts.assetPrice.setOracle(btcPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BTC) receipt: ', receipt);
                return contracts.assetPrice.setOracle(ethPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(ETH) receipt: ', receipt);
                return contracts.assetPrice.setOracle(bnbPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(BNB) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dAAPLPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dAAPL) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dTSLAPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(dTSLA) receipt: ', receipt);
                return contracts.assetPrice.setOracle(dipPriceKey, contracts.synthxOracle.address);
            })
            .then(receipt => {
                console.log('assetPrice.setOracle(DIP) receipt: ', receipt);
                console.log("oracle contracts deployment finished\n\n");

                const addrs = JSON.stringify(commonContractAddrs, null, '\t');

                fs.writeFile(contractAddrsFile, addrs, (err) => {
                    if (err) {
                        throw err;
                    }
                    console.log("contractAddrs saved");
                    return true;
                });
            });
    }
}