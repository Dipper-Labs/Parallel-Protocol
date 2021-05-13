const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json')

const Synthx = artifacts.require("Synthx");

module.exports = async function(deployer, network, accounts) {
    let contracts = {};
    contracts.synthx = await Synthx.at(contractAddrs.synthx);
    console.log(contracts.synthx.address);

    console.log("-------- mint synths -------- ");
    await deployer
        .then(() => {
            return contracts.synthx.mintFromCoin(Web3Utils.toWei('1000', 'ether'), {value: Web3Utils.toWei('1', 'ether')});
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
        });
}