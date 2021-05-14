const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json');

const Synthx = artifacts.require("Synthx");
const Synth = artifacts.require("Synth");
const Stats = artifacts.require("Stats");
const SynthxDToken = artifacts.require("SynthxDToken");

module.exports = async function(deployer, network, accounts) {
    let contracts = {};

    contracts.synthx = await Synthx.at(contractAddrs.synthx);
    contracts.dUSD = await Synth.at(contractAddrs.dUSD);
    contracts.stats = await Stats.at(contractAddrs.stats);
    contracts.synthxDToken = await SynthxDToken.at(contractAddrs.synthxDToken);
    contracts.dTSLA = await Synth.at(contractAddrs.dTSLA);
    contracts.dAPPLE = await Synth.at(contractAddrs.dAPPLE);

    await deployer
        .then(() => {
            console.log("-------- trade -------- ");
            // dUSD => dTSLA
            return contracts.synthx.trade(Web3Utils.fromAscii('dUSD'), Web3Utils.toWei('1', 'ether'), Web3Utils.fromAscii('dTSLA'));
        })
        .then((receipt) => {
            console.log('synthx.trade(dUSD => dTSLA) receipt: ', receipt);

            return contracts.dTSLA.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dTSLA balance:", Web3Utils.fromWei(balance, 'ether'));

            // dTSLA => dAPPLE
            return contracts.synthx.trade(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('4', 'milliether'), Web3Utils.fromAscii('dAPPLE'));
        })
        .then((receipt) => {
            console.log('synthx.trade(dTSLA => dAPPLE) receipt: ', receipt);
            return contracts.dTSLA.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dTSLA balance:", Web3Utils.fromWei(balance, 'ether'));
            return contracts.dAPPLE.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dAPPLE balance:", Web3Utils.fromWei(balance, 'ether'));
            // get synth asset
            return contracts.stats.getAssets(Web3Utils.fromAscii('Synth'), accounts[0]);
        })
        .then((assets) => {
            console.log("synth assets:", assets);
            // get stake asset
            return contracts.stats.getAssets(Web3Utils.fromAscii('Stake'), accounts[0]);
        })
        .then((stakeAssets) => {
            console.log("stake assets:", stakeAssets);
            // get vaullts
            return contracts.stats.getVaults(accounts[0]);
        })
        .then((vaults) => {
            console.log("getVaults:", vaults);
            // getTotalCollateral
            return contracts.stats.getTotalCollateral(accounts[0]);
        })
        .then((totalCollateral) => {
            console.log("getTotalCollateral:", totalCollateral)
        });
}