const contractAddrs = require('../finalContractAddrs.json');

const Resolver = artifacts.require("Resolver");
const SynthxDToken = artifacts.require("SynthxDToken");
const Issuer = artifacts.require("Issuer");
const History = artifacts.require("History");
const Liquidator = artifacts.require("Liquidator");
const Staker = artifacts.require("Staker");
const Holder = artifacts.require("Holder");
const Trader = artifacts.require("Trader");
const Market = artifacts.require("Market");
const SupplySchedule = artifacts.require("SupplySchedule");
const Stats = artifacts.require("Stats");
const Synthx = artifacts.require("Synthx");

module.exports = async function(deployer) {
    let contracts = {};

    contracts.resolver = await Resolver.at(contractAddrs.resolver);
    contracts.synthxDToken = await SynthxDToken.at(contractAddrs.synthxDToken);
    contracts.issuer = await Issuer.at(contractAddrs.issuer);
    contracts.history = await History.at(contractAddrs.history);
    contracts.liquidator = await Liquidator.at(contractAddrs.liquidator);
    contracts.staker = await Staker.at(contractAddrs.staker);
    contracts.holder = await Holder.at(contractAddrs.holder);
    contracts.trader = await Trader.at(contractAddrs.trader);
    contracts.market = await Market.at(contractAddrs.market);
    contracts.supplySchedule = await SupplySchedule.at(contractAddrs.supplySchedule);
    contracts.stats = await Stats.at(contractAddrs.stats);
    contracts.synthx = await Synthx.at(contractAddrs.synthx);

    await deployer
        .then(() => {
            return contracts.synthx.refreshCache();
        })
        .then((receipt) => {
            console.log('synthx.refreshCache receipt: ', receipt);
            return contracts.staker.refreshCache();
        })
        .then((receipt) => {
            console.log('staker.refreshCache receipt: ', receipt);
            return contracts.holder.refreshCache();
        })
        .then((receipt) => {
            console.log('holder.refreshCache receipt: ', receipt);
            return contracts.trader.refreshCache();
        })
        .then((receipt) => {
            console.log('trader.refreshCache receipt: ', receipt);
            return contracts.market.refreshCache();
        })
        .then((receipt) => {
            console.log('market.refreshCache receipt: ', receipt);
            return contracts.history.refreshCache();
        })
        .then((receipt) => {
            console.log('history.refreshCache receipt: ', receipt);
            return contracts.liquidator.refreshCache();
        })
        .then((receipt) => {
            console.log('liquidator.refreshCache receipt: ', receipt);
            return contracts.issuer.refreshCache();
        })
        .then((receipt) => {
            console.log('issuer.refreshCache receipt: ', receipt);
            return contracts.supplySchedule.refreshCache();
        })
        .then((receipt) => {
            console.log('supplySchedule.refreshCache receipt: ', receipt);
            return contracts.stats.refreshCache();
        })
        .then((receipt) => {
            console.log('stats.refreshCache receipt: ', receipt);
            return contracts.synthxDToken.refreshCache();
        })
        .then(receipt => {
            console.log('synthxDToken.refreshCache receipt: ', receipt);
        });
}
