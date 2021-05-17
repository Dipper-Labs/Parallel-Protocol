const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json');

const {checkUndefined} = require('./util');
const {AssetTypeSynth} = require('./common');

const SynthxOracle = artifacts.require("SynthxOracle");
const ChainLinkOracle = artifacts.require("ChainLinkOracle");
const AssetPrice = artifacts.require("AssetPrice");
const Resolver = artifacts.require("Resolver");
const Issuer = artifacts.require("Issuer");
const TokenStorage = artifacts.require("TokenStorage");
const Synth = artifacts.require("Synth");

// must setup before run script
const oracleType = 'SynthxOracle'; // ['SynthxOracle', 'ChainLinkOracle']
const synthName = 'dTSET'; // erc20 Name, string type
const synthSymbol = 'dTEST'; // erc20 symbol, string type
const synth = Web3Utils.fromAscii('dTEST'); // eg: dUSD, dTSLA, dAAPL
const synthPriceKey = Web3Utils.fromAscii('dTEST'); // eg BTC ETH BTC dAAPL dTSLA
const currentPrice = Web3Utils.toWei('0.0052836', 'ether'); // only for SynthxOracle, in USD
const chainLinkPriceContractAddr = ""; // only for ChainLinkOracle, for BSC chain query from https://docs.chain.link/docs/binance-smart-chain-addresses/

module.exports = async function(deployer) {
    let contracts = {};

    contracts.assetPrice = await AssetPrice.at(contractAddrs.assetPrice);
    contracts.resolver = await Resolver.at(contractAddrs.resolver);
    contracts.issuer = await Issuer.at(contractAddrs.issuer);
    if (oracleType === 'ChainLinkOracle') {
        contracts.oracle = await ChainLinkOracle.at(contractAddrs.chainLinkOracle);
    } else {
        contracts.oracle = await SynthxOracle.at(contractAddrs.synthxOracle);
    }

    await deployer
        .then(() => {
            return deployer.deploy(Synth);
        })
        .then(synth => {
            checkUndefined(synth);
            contracts.synth = synth;
            contractAddrs.synth = synth.address;
            return deployer.deploy(TokenStorage, contracts.synth.address);
        })
        .then((synthStorage) => {
            checkUndefined(synthStorage);
            contracts.synthStorage = synthStorage;
            contractAddrs.synthStorage = contracts.synthStorage.address;
            return contracts.synth.setStorage(synthStorage.address);
        })
        .then((receipt) => {
            console.log('setStorage receipts: ', receipt);
            return contracts.synth.initialize(contracts.issuer.address, synthName, synthSymbol, Web3Utils.fromAscii('erc20'));
        })
        .then(receipt => {
            console.log('initialize receipt: ', receipt);
            return contracts.resolver.addAsset(AssetTypeSynth, synth, contracts.synth.address);
        })
        .then(receipt => {
            console.log('resolver.addAsset receipt: ', receipt);
            return contracts.assetPrice.setOracle(synthPriceKey, contracts.oracle.address);
        })
        .then(receipt => {
            console.log('assetPrice.setOracle receipt: ', receipt);
            if (oracleType === 'ChainLinkOracle') {
                return contracts.oracle.setAggregator(synthPriceKey, chainLinkPriceContractAddr);
            }
            return contracts.oracle.setPrice(synthPriceKey, currentPrice);
        })
        .then(receipt => {
            if (oracleType === 'ChainLinkOracle') {
                console.log('ChainLinkOracle oracle.setPrice receipt: ', receipt);
            } else {
                console.log('SynthxOracle oracle.setAggregator receipt: ', receipt);
            }

            console.log('new synth address: ', contracts.synth.address);
            console.log('new synth storage address: ', contractAddrs.synthStorage);
        });
}