const fs = require('fs');
const Web3Utils = require('web3-utils');
const {checkUndefined} = require('./util');
const {nativeToken, fakeERC20Addr, foundationAddr, ecologyAddr, maxDelayTime} = require('./config');

const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");
const SettingStorage = artifacts.require("SettingStorage");
const IssuerStorage = artifacts.require("IssuerStorage");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");
const StakerStorage = artifacts.require("StakerStorage");
const HolderStorage = artifacts.require("HolderStorage");
const TraderStorage = artifacts.require("TraderStorage");

const Setting = artifacts.require("Setting");
const Resolver = artifacts.require("Resolver");
const Issuer = artifacts.require("Issuer");
const History = artifacts.require("History");
const Liquidator = artifacts.require("Liquidator");
const Staker = artifacts.require("Staker");
const Holder = artifacts.require("Holder");
const AssetPrice = artifacts.require("AssetPrice");
const Trader = artifacts.require("Trader");
const Market = artifacts.require("Market");
const SupplySchedule = artifacts.require("SupplySchedule");
const Stats = artifacts.require("Stats");
const Synthx = artifacts.require("Synthx");

module.exports = function(deployer) {
    let contracts = {};
    let contractAddrs = {};

    if ('' === foundationAddr) {
        console.log('foundation account must be setup in config.js');
        process.exit(-1);
    }

    if ('' === ecologyAddr) {
        console.log('ecology account must be setup in config.js');
        process.exit(-1);
    }

    deployer
        .then(function() {
            return deployer.deploy(Setting);
        })
        .then((setting) => {
            checkUndefined(setting);
            contracts.setting = setting;
            contractAddrs.setting = setting.address;
            return deployer.deploy(Resolver);
        })
        .then((resolver) => {
            checkUndefined(resolver);
            contracts.resolver = resolver;
            contractAddrs.resolver = resolver.address;
            return deployer.deploy(Issuer, contracts.resolver.address);
        })
        .then((issuer) => {
            checkUndefined(issuer);
            contracts.issuer = issuer;
            contractAddrs.issuer = issuer.address;
            return deployer.deploy(History, contracts.resolver.address);
        })
        .then((history) => {
            checkUndefined(history);
            contracts.history = history;
            contractAddrs.history = history.address;
            return deployer.deploy(Liquidator, contracts.resolver.address);
        })
        .then((liquidator) => {
            checkUndefined(liquidator);
            contracts.liquidator = liquidator;
            contractAddrs.liquidator = liquidator.address;
            return deployer.deploy(Staker, contracts.resolver.address);
        })
        .then((staker) => {
            checkUndefined(staker);
            contracts.staker = staker;
            contractAddrs.staker = staker.address;
            return deployer.deploy(Holder, contracts.resolver.address);
        })
        .then((holder) => {
            checkUndefined(holder);
            contracts.holder = holder;
            contractAddrs.holder = holder.address;
            return deployer.deploy(AssetPrice);
        })
        .then((assetPrice) => {
            checkUndefined(assetPrice);
            contracts.assetPrice = assetPrice;
            contractAddrs.assetPrice = assetPrice.address;
            return deployer.deploy(Trader, Resolver.address);
        })
        .then((trader) => {
            checkUndefined(trader);
            contracts.trader = trader;
            contractAddrs.trader = trader.address;
            return deployer.deploy(Market, Resolver.address);
        })
        .then((market) => {
            checkUndefined(market);
            contracts.market = market;
            contractAddrs.market = market.address;
            const startTime = Math.floor(Math.floor(Date.now()/1000)/60)*60;
            return deployer.deploy(SupplySchedule, Resolver.address, startTime, 0);
        })
        .then((supplySchedule) => {
            checkUndefined(supplySchedule);
            contracts.supplySchedule = supplySchedule;
            contractAddrs.supplySchedule = supplySchedule.address;
            return deployer.deploy(Stats, Resolver.address);
        })
        .then((stats) => {
            checkUndefined(stats);
            contracts.stats = stats;
            contractAddrs.stats = stats.address;
            return deployer.deploy(Synthx);
        })
        .then((synthx) => {
            checkUndefined(synthx);
            contracts.synthx = synthx;
            contractAddrs.synthx = synthx.address;
            return deployer.deploy(Storage);
        })

        // deploy storages
        .then((storage) => {
            contracts.storage = storage;
            checkUndefined(contracts.storage);
            return deployer.deploy(AddressStorage);
        })
        .then((addressStorage) => {
            contracts.addressStorage = addressStorage;
            checkUndefined(contracts.addressStorage);
            return deployer.deploy(SettingStorage, contracts.setting.address);
        })
        .then((settingStorage) => {
            contracts.settingStorage = settingStorage;
            checkUndefined(contracts.settingStorage);
            return deployer.deploy(IssuerStorage, contracts.issuer.address);
        })
        .then((issuerStorage) => {
            contracts.issuerStorage = issuerStorage;
            checkUndefined(contracts.issuerStorage);
            return deployer.deploy(LiquidatorStorage, contracts.liquidator.address);
        })
        .then((liquidatorStorage) => {
            contracts.liquidatorStorage = liquidatorStorage;
            checkUndefined(contracts.liquidatorStorage);
            return deployer.deploy(StakerStorage, contracts.staker.address);
        })
        .then((stakerStorage) => {
            contracts.stakerStorage = stakerStorage;
            checkUndefined(contracts.stakerStorage);
            return deployer.deploy(HolderStorage, contracts.holder.address);
        })
        .then((holderStorage) => {
            contracts.holderStorage = holderStorage;
            checkUndefined(contracts.holderStorage);
            return deployer.deploy(TraderStorage, contracts.trader.address);
        })

        // setup storages
        .then((traderStorage) => {
            contracts.traderStorage = traderStorage;
            checkUndefined(contracts.traderStorage);
            return contracts.setting.setStorage(contracts.settingStorage.address);
        })
        .then((receipt) => {
            console.log('setting.setStorage receipts: ', receipt);
            return contracts.issuer.setStorage(contracts.issuerStorage.address);
        })
        .then((receipt) => {
            console.log('issuer.setStorage receipts: ', receipt);
            return contracts.liquidator.setStorage(contracts.liquidatorStorage.address);
        })
        .then((receipt) => {
            console.log('liquidator.setStorage receipts: ', receipt);
            return contracts.staker.setStorage(contracts.stakerStorage.address);
        })
        .then((receipt) => {
            console.log('staker.setStorage receipts: ', receipt);
            return contracts.holder.setStorage(contracts.holderStorage.address);
        })
        .then((receipt) => {
            console.log('holder.setStorage receipts: ', receipt);
            return contracts.trader.setStorage(contracts.traderStorage.address);
        })

        // init nativeCoin as ETH
        .then((receipt) => {
            console.log('trader.setStorage receipts: ', receipt);
            return contracts.synthx.initialize(Resolver.address, Web3Utils.fromAscii(nativeToken));
        })
        .then((receipt) => {
            console.log('synthx.initialize receipt: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii(nativeToken), fakeERC20Addr);
        })

        // resolver setAddresses
        .then((receipt) => {
            console.log('resolver.addAsset(native) receipt: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Issuer'), contracts.issuer.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Issuer) receipts: ', receipt);
            return contracts.assetPrice.setMaxDelayTime(maxDelayTime);
        })
        .then((receipt) => {
            console.log('assetPrice.setMaxDelayTime receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Staker'), contracts.staker.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Staker) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Holder'), contracts.holder.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Holder) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('AssetPrice'), contracts.assetPrice.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(AssetPrice) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Setting'), contracts.setting.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Setting) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Trader'), contracts.trader.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Trader) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Market'), contracts.market.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Market) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('History'), contracts.history.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(History) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Liquidator'), contracts.liquidator.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Liquidator) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SupplySchedule'), contracts.supplySchedule.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(SupplySchedule) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Foundation'), foundationAddr);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Foundation) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Ecology'), ecologyAddr);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Ecology) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Synthx'), contracts.synthx.address);
        })

        // save addresses
        .then((receipt) => {
            console.log('resolver.setAddress(Synthx) receipts: ', receipt);
            console.log("contracts deployment finished\n\n");

            const addrs = JSON.stringify(contractAddrs, null, '\t');

            fs.writeFile('commonContractAddrs.json', addrs, (err) => {
                if (err) {
                    throw err;
                }
                console.log("commonContractAddrs saved");
            });
        });
};
