const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json')

const History = artifacts.require("History");

const topic = Web3Utils.fromAscii('Stake');

module.exports = async function(deployer, network, accounts) {
    const history = await History.at(contractAddrs.history);

    await deployer
        .then(() => {
            return history.getHistory(topic, accounts[0], 10, 1);
        })
        .then((result) => {
            console.log(result);
        });
}