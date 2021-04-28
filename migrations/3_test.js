const fs = require('fs');
const Web3Utils = require('web3-utils');

const Synthx = artifacts.require("Synthx");
const Synth = artifacts.require("Synth");
const Stats = artifacts.require("Stats");
const SynthxDToken = artifacts.require("SynthxDToken");

module.exports = async function(deployer, network, accounts) {
    let contractsAddrs = {};

    const data = fs.readFileSync('contractsAddrs.json', 'utf-8')
    contractsAddrs = JSON.parse(data.toString());

    console.log(contractsAddrs);

    let contracts = {};
    contracts.synthx = await Synthx.at(contractsAddrs.synthx);
    contracts.dUSD = await Synth.at(contractsAddrs.dUSD);
    contracts.stats = await Stats.at(contractsAddrs.stats);
    contracts.synthxDToken = await SynthxDToken.at(contractsAddrs.synthxDToken);
    contracts.dTSLA = await Synth.at(contractsAddrs.dTSLA);
    contracts.dAPPLE = await Synth.at(contractsAddrs.dAPPLE);

    console.log(contracts.synthx.address);
    console.log(contracts.dUSD.address);
    console.log(contracts.stats.address);
    console.log(contracts.synthxDToken.address);
    console.log(contracts.dTSLA.address);
    console.log(contracts.dAPPLE.address);

    console.log("-------- mint synths -------- ");
    await deployer
        .then(() => {
            return contracts.synthx.mintFromCoin({value: Web3Utils.toWei('1', 'ether')});
        })
        .then((receipt) => {
            console.log('synthx.mintFromCoin receipt: ', receipt);
            return contracts.dUSD.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dUSD balance:", Web3Utils.fromWei(balance, 'ether'));
            return contracts.synthxDToken.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dToken balance:", Web3Utils.fromWei(balance, 'ether'));
            return contracts.stats.getTotalCollateral(accounts[0]);
        })
        .then((totalCollateral) => {
            console.log("totalDebt:", Web3Utils.fromWei(totalCollateral.totalDebt, 'ether'));

            console.log("\n-------- burn synths -------- ");
            return contracts.synthx.burn(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('synthx.burn receipt: ', receipt);
            return contracts.dUSD.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dUSD balance:", Web3Utils.fromWei(balance, 'ether'));
            return contracts.synthxDToken.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("dToken balance:", Web3Utils.fromWei(balance, 'ether'));
            return contracts.stats.getTotalCollateral(accounts[0]);
        })
        .then((totalCollateral) => {
            console.log("totalDebt:", Web3Utils.fromWei(totalCollateral.totalDebt, 'ether'));
            return contracts.stats.getRewards(accounts[0]);
        })
        .then((reward) => {
            console.log("rewards: ", Web3Utils.fromWei(reward, 'ether'))
            return contracts.stats.getWithdrawable(accounts[0]);
        })
        .then((rewardable) => {
            console.log("getWithdrawable:", Web3Utils.fromWei(rewardable, 'ether'));

            console.log("-------- claim rewards -------- ");
            return contracts.synthx.claimReward();
        })
        .then((receipt) => {
            console.log('synthx.claimReward receipt: ', receipt);

            return contracts.synthxToken.balanceOf(accounts[0]);
        })
        .then((balance) => {
            console.log("synthx balance:", Web3Utils.fromWei(balance, 'ether'));

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
            return contracts.synthx.trade(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('1', 'ether'), Web3Utils.fromAscii('dAPPLE'));
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
            console.log("stake assets:", res);
            // get vaullts
            return contracts.stats.getVaults(accounts[0]);
        })
        .then((vaults) => {
            console.log("getVaults:", vaults);
            // getTotalCollateral
            contracts.stats.getTotalCollateral(accounts[0]);
        })
        .then((totalCollateral) => {
            console.log("getTotalCollateral:", totalCollateral)
        });
}