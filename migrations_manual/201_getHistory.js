const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json')

const History = artifacts.require("History");

const topic = Web3Utils.fromAscii('Stake');

module.exports = async function(deployer, network, accounts) {
    let contracts = {};
    contracts.history = await History.at(contractAddrs.history);
    console.log(contracts.history.address);

    await deployer
        .then(() => {
            return contracts.history.getHistory(topic, accounts[0], 10, 1);
        })
        .then((result) => {
            console.log(result);
        });
}