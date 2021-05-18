const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json')

const Synthx = artifacts.require("Synthx");
const Synth = artifacts.require("Synth");
const Stats = artifacts.require("Stats");

module.exports = async function(deployer, network, accounts) {
    let contracts = {};
    contracts.synthx = await Synthx.at(contractAddrs.synthx);
    contracts.dTSLA = await Synth.at(contractAddrs.dTSLA);
    contracts.dAAPL = await Synth.at(contractAddrs.dAPPL);
    contracts.stats = await Stats.at(contractAddrs.stats);

    await deployer
        .then(() => {
            return contracts.dTSLA.balanceOf(accounts[0]);
        })
        .then(balance => {
            console.log('dTSLA balance: ', Web3Utils.fromWei(balance, 'ether'));
            return contracts.dAAPL.balanceOf(accounts[0]);
        })
        .then(balance => {
            console.log('dAAPL balance: ', Web3Utils.fromWei(balance, 'ether'));
            return contracts.synthx.mintFromToken(Web3Utils.fromAscii('dAPPL'), Web3Utils.toWei('1', 'ether'), Web3Utils.toWei('0.1', 'ether'));
        })
        .then(receipt => {
            console.log('synthx.mintFromToken receipt: ', receipt);
            return contracts.dTSLA.balanceOf(accounts[0]);
        })
        .then(balance => {
            console.log('dTSLA balance: ', Web3Utils.fromWei(balance, 'ether'));
            return contracts.dAAPL.balanceOf(accounts[0]);
        })
        .then(balance => {
            console.log('dAAPL balance: ', Web3Utils.fromWei(balance, 'ether'));
        });
}