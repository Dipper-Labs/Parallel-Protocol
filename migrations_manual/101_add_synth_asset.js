const Web3Utils = require('web3-utils');

const contractAddrs = require('../contractAddrs.json');

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
const oracleType = 'ChainLinkOracle'; // ['SynthxOracle', 'ChainLinkOracle']
const synthName = 'dTSET'; // erc20 Name, string type
const synthSymbol = 'dTEST'; // erc20 symbol, string type
const synth = Web3Utils.fromAscii('dTEST'); // eg: dUSD, dTSLA, dAAPL
const synthPriceKey = Web3Utils.fromAscii('dTEST'); // eg BTC ETH BTC dAAPL dTSLA

module.exports = async function(deployer) {
    let contracts = {};

    contracts.synthxOracle = await SynthxOracle.at(contractAddrs.synthxOracle);
    contracts.chainLinkOracle = await ChainLinkOracle.at(contractAddrs.chainLinkOracle);
    contracts.assetPrice = await AssetPrice.at(contractAddrs.assetPrice);
    contracts.resolver = await Resolver.at(contractAddrs.resolver);
    contracts.issuer = await Issuer.at(contractAddrs.issuer);

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
            if (oracleType === 'ChainLinkOracle') {
                return contracts.assetPrice.setOracle(synthPriceKey, contracts.chainLinkOracle.address);
            } else {
                return contracts.assetPrice.setOracle(synthPriceKey, contracts.synthxOracle.address);
            }
        })
        .then(receipt => {
            console.log('assetPrice.setOracle receipt: ', receipt);
            console.log('new synth address: ', contracts.synth.address);
            console.log('new synth storage address: ', contractAddrs.synthStorage.address);
        });
}