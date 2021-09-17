const Web3Utils = require('web3-utils');

const contractAddrs = require('../finalContractAddrs.json')

const Stats = artifacts.require("Stats");

const topic = Web3Utils.fromAscii('Stake');

module.exports = async function(deployer, network, accounts) {
    const stats = await Stats.at(contractAddrs.stats);

    await deployer
        .then(() => {
            return stats.getVaults('0x5eb14128446e13357a15a8ee090b3282d090462f');
        })
        .then((result) => {
            console.log(result);
        });
}