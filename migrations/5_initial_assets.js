const fs = require('fs');
const Web3Utils = require('web3-utils');

const {checkUndefined} = require('./util');
const {AssetTypeStake, AssetTypeSynth, sDIP, dToken, Synth_dUSD, Synth_dAPPL, Synth_dTSLA} = require('./common');
const {NativeToken, NativeERC20Addr, BTCToken, BTCERC20Addr} = require('./config');

const contractAddrs = require('../contractAddrs.json');

const Resolver = artifacts.require("Resolver");
const Issuer = artifacts.require("Issuer");
const TokenStorage = artifacts.require("TokenStorage");
const Synth = artifacts.require("Synth");
const SynthxToken = artifacts.require("SynthxToken");   // sDIP
const SynthxDToken = artifacts.require("SynthxDToken"); // DToken

module.exports = async function(deployer) {
    let contracts = {};

    contracts.resolver = await Resolver.at(contractAddrs.resolver);
    contracts.issuer = await Issuer.at(contractAddrs.issuer);


    await deployer
        .then(() => {
            return deployer.deploy(Synth);
        })
        .then((dUSD) => {
            checkUndefined(dUSD);
            contracts.dUSD = dUSD;
            contractAddrs.dUSD = dUSD.address;
            return deployer.deploy(SynthxToken);
        })
        .then((synthxToken) => {
            checkUndefined(synthxToken);
            contracts.synthxToken = synthxToken;
            contractAddrs.synthxToken = synthxToken.address;
            return deployer.deploy(SynthxDToken, Resolver.address);
        })
        .then((synthxDToken) => {
            checkUndefined(synthxDToken);
            contracts.synthxDToken = synthxDToken;
            contractAddrs.synthxDToken = synthxDToken.address;
            return deployer.deploy(Synth);
        })
        .then((dTSLA) => {
            checkUndefined(dTSLA);
            contracts.dTSLA = dTSLA;
            contractAddrs.dTSLA = dTSLA.address;
            return deployer.deploy(Synth);
        })
        .then((dAPPL) => {
            checkUndefined(dAPPL);
            contracts.dAPPL = dAPPL;
            contractAddrs.dAPPL = dAPPL.address;
            return deployer.deploy(TokenStorage, contracts.dUSD.address);
        })
        .then((dUSDStorage) => {
            contracts.dUSDStorage = dUSDStorage;
            checkUndefined(contracts.dUSDStorage);
            return deployer.deploy(TokenStorage, contracts.synthxToken.address);
        })
        .then((synthxTokenStorage) => {
            contracts.synthxTokenStorage = synthxTokenStorage;
            checkUndefined(contracts.synthxTokenStorage);
            return deployer.deploy(TokenStorage, contracts.synthxDToken.address);
        })
        .then((synthxDTokenStorage) => {
            contracts.synthxDTokenStorage = synthxDTokenStorage;
            checkUndefined(contracts.synthxDTokenStorage);
            return deployer.deploy(TokenStorage, contracts.dTSLA.address);
        })
        .then((dTSLAStorage) => {
            contracts.dTSLAStorage = dTSLAStorage;
            checkUndefined(contracts.dTSLAStorage);
            return deployer.deploy(TokenStorage, contracts.dAPPL.address);
        })
        .then((dAPPLStorage) => {
            contracts.dAPPLStorage = dAPPLStorage;
            checkUndefined(contracts.dAPPLStorage);
            return contracts.dUSD.setStorage(contracts.dUSDStorage.address);
        })
        .then((receipt) => {
            console.log('dUSD.setStorage receipts: ', receipt);
            return contracts.synthxToken.setStorage(contracts.synthxTokenStorage.address);
        })
        .then((receipt) => {
            console.log('synthxToken.setStorage receipts: ', receipt);
            return contracts.synthxDToken.setStorage(contracts.synthxDTokenStorage.address);
        })
        .then((receipt) => {
            console.log('synthxDToken.setStorage receipts: ', receipt);
            return contracts.dTSLA.setStorage(contracts.dTSLAStorage.address);
        })
        .then((receipt) => {
            console.log('dTSLA.setStorage receipts: ', receipt);
            return contracts.dAPPL.setStorage(contracts.dAPPLStorage.address);
        })
        .then((receipt) => {
            console.log('dAPPL.setStorage receipts: ', receipt);
            return contracts.dUSD.initialize(contracts.issuer.address, "dUSD", "dUSD", Web3Utils.fromAscii('erc20'));
        })
        .then((receipt) => {
            console.log('dUSD.initialize receipts: ', receipt);
            return contracts.synthxToken.initialize(contracts.resolver.address);
        })
        .then((receipt) => {
            console.log('synthxToken.initialize receipts: ', receipt);
            return contracts.synthxDToken.initialize();
        })
        .then((receipt) => {
            console.log('synthxDToken.initialize receipts: ', receipt);
            return contracts.dTSLA.initialize(contracts.issuer.address, "dTSLA", "dTSLA", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log('dTSLA.initialize receipts: ', receipt);
            return contracts.dAPPL.initialize(contracts.issuer.address, "dAPPL", "dAPPL", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log('dAPPL.initialize receipts: ', receipt);
            return contracts.resolver.setAddress(sDIP, contracts.synthxToken.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(sDIP) receipts: ', receipt);
            return contracts.resolver.setAddress(dToken, contracts.synthxDToken.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(dToken) receipts: ', receipt);
            return contracts.resolver.addAsset(AssetTypeSynth, Synth_dUSD, contracts.dUSD.address);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Synth-dUSD) receipts: ', receipt);
            return contracts.resolver.addAsset(AssetTypeSynth, Synth_dTSLA, contracts.dTSLA.address);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Synth-dTSLA) receipts: ', receipt);
            return contracts.resolver.addAsset(AssetTypeSynth, Synth_dAPPL, contracts.dAPPL.address);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Stake-Native) receipts: ', receipt);
            return contracts.resolver.addAsset(AssetTypeStake, NativeToken, NativeERC20Addr);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Stake-BTC) receipts: ', receipt);
            return contracts.resolver.addAsset(AssetTypeStake, BTCToken, BTCERC20Addr);
        })

        // save contract addresses
        .then(receipt => {
            console.log('resolver.addAsset(Synth-dAAPL) receipt: ', receipt);
            console.log("oracle contracts deployed finish\n\n");

            const addrs = JSON.stringify(contractAddrs, null, '\t');

            fs.writeFile('finalContractAddrs.json', addrs, (err) => {
                if (err) {
                    throw err;
                }
                console.log("finalContractAddrs saved");

                return true;
            });
        });
}
