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
    let contractsAddrs = {};

    deployer
        .then(function() {
            return deployer.deploy(Setting);
        })
        .then((setting) => {
            contracts.setting = setting;
            contractsAddrs.setting = setting.address;
            checkUndefined(contracts.setting);
            return deployer.deploy(Resolver);
        })
        .then((resolver) => {
            contracts.resolver = resolver;
            contractsAddrs.resolver = resolver.address;
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
            contractsAddrs.stats = stats.address;
            checkUndefined(contracts.stats);
            return deployer.deploy(Synthx);
        })
        .then((synthx) => {
            contracts.synthx = synthx;
            contractsAddrs.synthx = synthx.address;
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
            return contracts.setting.setStorage(contracts.settingStorage.address);
        })
        .then((receipt) => {
            console.log('setting.setStorage receipts: ', receipt);
            contracts.escrow.setStorage(contracts.escrowStorage.address);
        })
        .then((receipt) => {
            console.log('escrow.setStorage receipts: ', receipt);
            contracts.issuer.setStorage(contracts.issuerStorage.address);
        })
        .then((receipt) => {
            console.log('issuer.setStorage receipts: ', receipt);
            contracts.liquidator.setStorage(contracts.liquidatorStorage.address);
        })
        .then((receipt) => {
            console.log('liquidator.setStorage receipts: ', receipt);
            contracts.staker.setStorage(contracts.stakerStorage.address);
        })
        .then((receipt) => {
            console.log('staker.setStorage receipts: ', receipt);
            contracts.oracle.setStorage(contracts.oracleStorage.address);
        })
        .then((receipt) => {
            console.log('oracle.setStorage receipts: ', receipt);
            contracts.trader.setStorage(contracts.traderStorage.address);
        })
        .then((receipt) => {
            console.log('trader.setStorage receipts: ', receipt);
            return contracts.synthx.initialize(Resolver.address, Web3Utils.fromAscii('ETH'));
        })
        .then((receipt) => {
            console.log('synthx.initialize receipt:', receipt);
            // resolver.setAddress should be done before tokens initialize
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Issuer'), contracts.issuer.address);
        })
        .then((receipt) => {
            console.log('resolver.setStorage receipts: ', receipt);
            return deployer.deploy(Synth);
        })
        .then((dUSD) => {
            contracts.dUSD = dUSD;
            contractsAddrs.dUSD = dUSD.address;
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
            contractsAddrs.dTSLA = dTSLA.address;
            return deployer.deploy(Synth);
        })
        .then((dAPPLE) => {
            contracts.dAPPLE = dAPPLE;
            checkUndefined(contracts.dAPPLE);
            contractsAddrs.dAPPLE = dAPPLE.address;
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
            console.log('dUSD.setStorage receipts: ', receipt);
            return contracts.synthxToken.setStorage(contracts.synthxTokenStorage.address);
        })
        .then((receipt) => {
            console.log('synthxToken.setStorage receipts: ', receipt);
            return contracts.synthxDToken.setStorage(contracts.synthxDTokenStorage.address);
        })
        .then((receipt) => {
            console.log('synthxDToken.setStorage receipts: ', receipt);
            return contracts.dTSLA.setStorage(contracts.dTSLAStorage.address);
        })
        .then((receipt) => {
            console.log('dTSLA.setStorage receipts: ', receipt);
            return contracts.dAPPLE.setStorage(contracts.dAPPLEStorage.address);
        })
        .then((receipt) => {
            console.log('dAPPLE.setStorage receipts: ', receipt);
            return contracts.dUSD.initialize(contracts.issuer.address, "dUSD", "dUSD", Web3Utils.fromAscii('erc20'));
        })
        .then((receipt) => {
            console.log('dUSD.initialize receipts: ', receipt);
            return contracts.synthxToken.initialize(contracts.resolver.address);
        })
        .then((receipt) => {
            console.log('synthxToken.initialize receipts: ', receipt);
            return contracts.synthxDToken.initialize();
        })
        .then((receipt) => {
            console.log('synthxDToken.initialize receipts: ', receipt);
            return contracts.dTSLA.initialize(contracts.issuer.address, "dTSLA", "dTSLA", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log('dTSLA.initialize receipts: ', receipt);
            return contracts.dAPPLE.initialize(contracts.issuer.address, "dAPPLE", "dAPPLE", Web3Utils.fromAscii('2'));
        })
        .then((receipt) => {
            console.log('dAPPLE.initialize receipts: ', receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2000', 'ether'));
        })
        .then((receipt) => {
            console.log('oracle.setPrice(ETH) receipts: ', receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('BTC'), Web3Utils.toWei('50000', 'ether'));
        })
        .then((receipt) => {
            console.log('oracle.setPrice(BTC) receipts: ', receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('750', 'ether'));
        })
        .then((receipt) => {
            console.log('oracle.setPrice(dTSLA) receipts: ', receipt);
            return contracts.oracle.setPrice(Web3Utils.fromAscii('dAPPLE'), Web3Utils.toWei('150', 'ether'));
        })
        .then((receipt) => {
            console.log('oracle.setPrice(dAPPLE) receipts: ', receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('ETH'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle(ETH) receipts: ', receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('BTC'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle(BTC) receipts: ', receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('dTSLA'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle(dTSLA) receipts: ', receipt);
            return contracts.assetPrice.setOracle(Web3Utils.fromAscii('dAPPLE'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('assetPrice.setOracle(dAPPLE) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Escrow'), contracts.escrow.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Escrow) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Staker'), contracts.staker.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Staker) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('AssetPrice'), contracts.assetPrice.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(AssetPrice) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Setting'), contracts.setting.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Setting) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Oracle'), contracts.oracle.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Oracle) receipts: ', receipt);
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
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Team'), accounts[0]);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Team) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('Synthx'), contracts.synthx.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(Synthx) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SynthxToken'), contracts.synthxToken.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(SynthxToken) receipts: ', receipt);
            return contracts.resolver.setAddress(Web3Utils.fromAscii('SynthxDToken'), contracts.synthxDToken.address);
        })
        .then((receipt) => {
            console.log('resolver.setAddress(SynthxDToken) receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii('ETH'), accounts[0]);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Stake-ETH) receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dUSD'), contracts.dUSD.address);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Synth-dUSD) receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dTSLA'), contracts.dTSLA.address);
        })
        .then((receipt) => {
            console.log(receipt);
            console.log('resolver.addAsset(Synth-dTSLA) receipts: ', receipt);
            return contracts.resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dAPPLE'), contracts.dAPPLE.address);
        })
        .then((receipt) => {
            console.log('resolver.addAsset(Synth-dAPPLE) receipts: ', receipt);
            return contracts.synthx.refreshCache();
        })
        .then((receipt) => {
            console.log('synthx.refreshCache receipt: ', receipt);
            return contracts.escrow.refreshCache();
        })
        .then((receipt) => {
            console.log('escrow.refreshCache receipt: ', receipt);
            return contracts.staker.refreshCache();
        })
        .then((receipt) => {
            console.log('staker.refreshCache receipt: ', receipt);
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
        .then((receipt) => {
            console.log('synthxDToken.refreshCache receipt: ', receipt);
            return contracts.setting.setCollateralRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setCollateralRate receipt: ', receipt);
            return contracts.setting.setLiquidationRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('1', 'ether'));
        })
        .then((receipt) => {
            console.log('setting.setLiquidationRate receipt: ', receipt);
            return contracts.setting.setLiquidationDelay(36000);
        })
        .then((receipt) => {
            console.log('setting.setLiquidationDelay receipt: ', receipt);
            return contracts.setting.setTradingFeeRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'milliether'));
        })
        .then((receipt) => {
            console.log('setting.setTradingFeeRate receipt: ', receipt);
            return contracts.setting.setMintPeriodDuration(1); // second
        })
        .then((receipt) => {
            console.log('setting.setMintPeriodDuration receipt: ', receipt);
            console.log("contracts deployment finished\n\n");

            const addrsData = JSON.stringify(contractsAddrs);

            fs.writeFile('contractsAddrs.json', addrsData, (err) => {
                if (err) {
                    throw err;
                }
                console.log("contractsAddrs saved");
            });
        })
};
