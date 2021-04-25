const fs = require('fs');
const Web3Utils = require('web3-utils');

const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");
const SettingStorage = artifacts.require("SettingStorage");
const IssuerStorage = artifacts.require("IssuerStorage");
const EscrowStorage = artifacts.require("EscrowStorage");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");
const StakerStorage = artifacts.require("StakerStorage");
const OracleStorage = artifacts.require("OracleStorage");
const TraderStorage = artifacts.require("TraderStorage");
const TokenStorage = artifacts.require("TokenStorage");

const Setting = artifacts.require("Setting");
const Resolver = artifacts.require("Resolver");
const Issuer = artifacts.require("Issuer");
const Escrow = artifacts.require("Escrow");
const History = artifacts.require("History");
const Liquidator = artifacts.require("Liquidator");
const Staker = artifacts.require("Staker");
const AssetPrice = artifacts.require("AssetPrice");
const Oracle = artifacts.require("SynthxOracle");
const Trader = artifacts.require("Trader");
const Market = artifacts.require("Market");
const SupplySchedule = artifacts.require("SupplySchedule");
const Stats = artifacts.require("Stats");
const Synthx = artifacts.require("Synthx");

const Synth = artifacts.require("Synth");
const SynthxToken = artifacts.require("SynthxToken");   // sDIP
const SynthxDToken = artifacts.require("SynthxDToken"); // DToken

function checkUndefined(obj) {
    if (obj == undefined) {
        console.log('undefined');
        process.exit(-1);
    } else {
        console.log(obj.address);
    }
}

module.exports = function(deployer, network, accounts) {
    let contracts = {};

    deployer
        .then(function() {
            return deployer.deploy(Setting);
        })
        .then((setting) => {
            contracts.setting = setting;
            checkUndefined(contracts.setting);
            return deployer.deploy(Resolver);
        })
        .then((resolver) => {
            contracts.resolver = resolver;
            checkUndefined(contracts.resolver);
            return deployer.deploy(Escrow, contracts.resolver.address);
        })
        .then((escrow) => {
            contracts.escrow = escrow;
            checkUndefined(contracts.escrow);
            return deployer.deploy(Issuer, contracts.resolver.address);
        })
        .then((issuer) => {
            contracts.issuer = issuer;
            checkUndefined(contracts.issuer);
            return deployer.deploy(History, contracts.resolver.address);
        })
        .then((history) => {
            contracts.history = history;
            checkUndefined(contracts.history);
            return deployer.deploy(Liquidator, contracts.resolver.address);
        })
        .then((liquidator) => {
            contracts.liquidator = liquidator;
            checkUndefined(contracts.liquidator);
            return deployer.deploy(Staker, contracts.resolver.address);
        })
        .then((staker) => {
            contracts.staker = staker;
            checkUndefined(contracts.staker);
            return deployer.deploy(AssetPrice);
        })
        .then((assetPrice) => {
            contracts.assetPrice = assetPrice;
            checkUndefined(contracts.assetPrice);
            return deployer.deploy(Oracle);
        })
        .then((oracle) => {
            contracts.oracle = oracle;
            checkUndefined(contracts.oracle);
            return deployer.deploy(Trader, Resolver.address);
        })
        .then((trader) => {
            contracts.trader = trader;
            checkUndefined(contracts.trader);
            return deployer.deploy(Market, Resolver.address);
        })
        .then((market) => {
            contracts.market = market;
            checkUndefined(contracts.market);
            return deployer.deploy(SupplySchedule, Resolver.address, 0, 0);
        })
        .then((supplySchedule) => {
            contracts.supplySchedule = supplySchedule;
            checkUndefined(contracts.supplySchedule);
            return deployer.deploy(Stats, Resolver.address);
        })
        .then((stats) => {
            contracts.stats = stats;
            checkUndefined(contracts.stats);
            return deployer.deploy(Synthx);
        })
        .then((synthx) => {
            contracts.synthx = synthx;
            checkUndefined(contracts.synthx);
            return deployer.deploy(Storage);
        })
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
            return deployer.deploy(EscrowStorage, contracts.escrow.address);
        })
        .then((escrowStorage) => {
            contracts.escrowStorage = escrowStorage;
            checkUndefined(contracts.escrowStorage);
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
            return deployer.deploy(OracleStorage, contracts.oracle.address);
        })
        .then((oracleStorage) => {
            contracts.oracleStorage = oracleStorage;
            checkUndefined(contracts.oracleStorage);
            return deployer.deploy(TraderStorage, contracts.trader.address);
        })
        .then((traderStorage) => {
            contracts.traderStorage = traderStorage;
            checkUndefined(contracts.traderStorage);
        })
        .then(() => {
            contracts.setting.setStorage(contracts.settingStorage.address);
        })
        .then(() => {
            contracts.escrow.setStorage(contracts.escrowStorage.address);
        })
        .then(() => {
            contracts.issuer.setStorage(contracts.issuerStorage.address);
        })
        .then(() => {
            contracts.liquidator.setStorage(contracts.liquidatorStorage.address);
        })
        .then(() => {
            contracts.staker.setStorage(contracts.stakerStorage.address);
        })
        .then(() => {
            contracts.oracle.setStorage(contracts.oracleStorage.address);
        })
        .then(() => {
            contracts.trader.setStorage(contracts.traderStorage.address);
        })
        .then(() => {
            return contracts.synthx.initialize(Resolver.address, Web3Utils.fromAscii('ETH'));
        })
        .then((receipt) => {
            console.log(receipt);
            // resolver.setAddress should be done before tokens initialize
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Issuer'), contracts.issuer.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return deployer.deploy(Synth);
        })
        .then((dUSD) => {
            contracts.dUSD = dUSD;
            checkUndefined(contracts.dUSD);
            return deployer.deploy(SynthxToken);
        })
        .then((synthxToken) => {
            contracts.synthxToken = synthxToken;
            checkUndefined(contracts.synthxToken);
            return deployer.deploy(SynthxDToken, Resolver.address);
        })
        .then((synthxDToken) => {
            contracts.synthxDToken = synthxDToken;
            checkUndefined(contracts.synthxDToken);
            return deployer.deploy(Synth);
        })
        .then((dTSLA) => {
            contracts.dTSLA = dTSLA;
            checkUndefined(contracts.dTSLA);
            return deployer.deploy(Synth);
        })
        .then((dAPPLE) => {
            contracts.dAPPLE = dAPPLE;
            checkUndefined(contracts.dAPPLE);
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
            return deployer.deploy(TokenStorage, contracts.dAPPLE.address);
        })
        .then((dAPPLEStorage) => {
            contracts.dAPPLEStorage = dAPPLEStorage;
            checkUndefined(contracts.dAPPLEStorage);
        })
        .then(() => {
            return contracts.dUSD.setStorage(contracts.dUSDStorage.address);
        })
        .then((receipt) => {
            return contracts.synthxToken.setStorage(contracts.synthxTokenStorage.address);
        })
        .then((receipt) => {
            return contracts.synthxDToken.setStorage(contracts.synthxDTokenStorage.address);
        })
        .then((receipt) => {
            return contracts.dTSLA.setStorage(contracts.dTSLAStorage.address);
        })
        .then((receipt) => {
            return contracts.dAPPLE.setStorage(contracts.dAPPLEStorage.address);
        })
        .then((receipt) => {
            console.log(receipt);
        })
        .then(() => {
            return contracts.dUSD.initialize(contracts.issuer.address, "dUSD", "dUSD", Web3Utils.fromAscii('erc20'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.synthxToken.initialize(contracts.resolver.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.synthxDToken.initialize();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.dTSLA.initialize(contracts.issuer.address, "dTSLA", "dTSLA", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.dAPPLE.initialize(contracts.issuer.address, "dAPPLE", "dAPPLE", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2000', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('BTC'), Web3Utils.toWei('50000', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('750', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('dAPPLE'), Web3Utils.toWei('150', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('ETH'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('BTC'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('dTSLA'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('dAPPLE'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Escrow'), contracts.escrow.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Staker'), contracts.staker.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('AssetPrice'), contracts.assetPrice.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Setting'), contracts.setting.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Oracle'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Trader'), contracts.trader.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Market'), contracts.market.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('History'), contracts.history.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Liquidator'), contracts.liquidator.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SupplySchedule'), contracts.supplySchedule.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Team'), accounts[0]);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Synthx'), contracts.synthx.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SynthxToken'), contracts.synthxToken.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SynthxDToken'), contracts.synthxDToken.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii('ETH'), accounts[0]);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dUSD'), contracts.dUSD.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dTSLA'), contracts.dTSLA.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dAPPLE'), contracts.dAPPLE.address);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.synthx.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.escrow.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.staker.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.trader.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.market.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.hitory.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.liquidator.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.issuer.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.supplySchedule.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.stats.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.synthxDToken.refreshCache();
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.setting.setCollateralRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.setting.setLiquidationRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.setting.setLiquidationDelay(36000);
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.setting.setTradingFeeRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'milliether'));
        })
        .then((receipt) => {
            console.log(receipt);
            return contracts.setting.setMintPeriodDuration(1); // second
        })
        .then((receipt) => {
            console.log(receipt);

            console.log("contracts deployment finished\n\n");
            const data = JSON.stringify(contracts);

            fs.writeFile('contracts.json', data, (err) => {
                if (err) {
                    throw err;
                }
                console.log("contracts saved");
            });
        })
};
