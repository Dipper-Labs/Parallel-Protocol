const Web3Utils = require('web3-utils');

const Migrations = artifacts.require("Migrations");

const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");

const Setting = artifacts.require("Setting");
const SettingStorage = artifacts.require("SettingStorage");

const Resolver = artifacts.require("Resolver");

const Issuer = artifacts.require("Issuer");
const IssuerStorage = artifacts.require("IssuerStorage");

const Escrow = artifacts.require("Escrow");
const EscrowStorage = artifacts.require("EscrowStorage");

const History = artifacts.require("History");

const Liquidator = artifacts.require("Liquidator");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");

const Staker = artifacts.require("Staker");
const StakerStorage = artifacts.require("StakerStorage");

const AssetPrice = artifacts.require("AssetPrice");

const SynthxOracle = artifacts.require("SynthxOracle");
const OracleStorage = artifacts.require("OracleStorage");

const Trader = artifacts.require("Trader");
const TraderStorage = artifacts.require("TraderStorage");

const Market = artifacts.require("Market");
const Special = artifacts.require("Special");
const SupplySchedule = artifacts.require("SupplySchedule");

const SynthxToken = artifacts.require("SynthxToken");

const Synthx = artifacts.require("Synthx");

const DUSD = artifacts.require("Synth");
const TokenStorage = artifacts.require("TokenStorage");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(Migrations);

    await deployer.deploy(Storage);
    await deployer.deploy(AddressStorage);

    const settingInstance = await deployer.deploy(Setting);
    await deployer.deploy(SettingStorage, Setting.address);
    await settingInstance.setStorage(SettingStorage.address);

    const resolverInstance = await deployer.deploy(Resolver);

    const escrowInstance = await deployer.deploy(Escrow, Resolver.address);
    await deployer.deploy(EscrowStorage, Escrow.address);
    await escrowInstance.setStorage(EscrowStorage.address);
    
    const issuerInstance = await deployer.deploy(Issuer, Resolver.address);
    await deployer.deploy(IssuerStorage, Issuer.address);
    await issuerInstance.setStorage(IssuerStorage.address);

    // must done before 'synthxTokenInstance.initialize(Resolver.address);'
    await resolverInstance.setAddress(Web3Utils.fromAscii('Issuer'), Issuer.address);
    const synthxTokenInstance = await deployer.deploy(SynthxToken);
    await synthxTokenInstance.initialize(Resolver.address);

    const hitoryInstance = await deployer.deploy(History, Resolver.address);

    const liquidatorInstance = await deployer.deploy(Liquidator, Resolver.address);
    await deployer.deploy(LiquidatorStorage, Liquidator.address);
    await liquidatorInstance.setStorage(LiquidatorStorage.address)


    const stakerInstance = await deployer.deploy(Staker, Resolver.address);
    await deployer.deploy(StakerStorage, Staker.address);
    await stakerInstance.setStorage(StakerStorage.address);

    const dUSDInstance = await deployer.deploy(DUSD);
    await deployer.deploy(TokenStorage, DUSD.address);
    await dUSDInstance.setStorage(TokenStorage.address);
    await dUSDInstance.initialize(Issuer.address, "dUSD", "dUSD", Web3Utils.fromAscii('erc20'));

    const assetPriceInstace = await deployer.deploy(AssetPrice);

    const SynthxOracleInstance = await deployer.deploy(SynthxOracle);
    await deployer.deploy(OracleStorage, SynthxOracle.address);
    await SynthxOracleInstance.setStorage(OracleStorage.address);

    assetPriceInstace.setOracle(Web3Utils.fromAscii('ETH'), SynthxOracle.address);
    SynthxOracleInstance.setPrice(Web3Utils.fromAscii('ETH'), 10000);

    const traderInstance = await deployer.deploy(Trader, Resolver.address);
    await deployer.deploy(TraderStorage, Trader.address);
    await traderInstance.setStorage(TraderStorage.address);

    const marketInstance = await deployer.deploy(Market, Resolver.address);
    await deployer.deploy(Special, Resolver.address);
    const supplyScheduleInstance = await deployer.deploy(SupplySchedule, Resolver.address, 0, 0);


    await resolverInstance.setAddress(Web3Utils.fromAscii('Escrow'), Escrow.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Staker'), Staker.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('AssetPrice'), AssetPrice.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Setting'), Setting.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Oracle'), SynthxOracle.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Trader'), Trader.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('SynthxToken'), SynthxToken.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Market'), Market.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('History'), History.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Liquidator'), Liquidator.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('SupplySchedule'), SupplySchedule.address);

    // resolver, add stake asset
    await resolverInstance.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii('ETH'), accounts[0]);
    await resolverInstance.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dUSD'), DUSD.address);

    // setting

    let res = await settingInstance.getCollateralRate(Web3Utils.fromAscii('ETH'));
    console.log("CollateralRate:", res.toString());

    settingInstance.setCollateralRate(Web3Utils.fromAscii('ETH'), 1);
    settingInstance.setLiquidationRate(Web3Utils.fromAscii('ETH'), 1);
    settingInstance.setLiquidationDelay(36000);
    settingInstance.setTradingFeeRate(Web3Utils.fromAscii('ETH'), 1);
    settingInstance.setMintPeriodDuration(36000); // second

    await settingInstance.getCollateralRate(Web3Utils.fromAscii('ETH'));

    const synthxInstance = await deployer.deploy(Synthx);
    synthxInstance.initialize(Resolver.address, Web3Utils.fromAscii('ETH'));

    await resolverInstance.setAddress(Web3Utils.fromAscii('Synthx'), Synthx.address);

    // refresh DNS
    await synthxInstance.refreshCache();
    await escrowInstance.refreshCache();
    await stakerInstance.refreshCache();
    await traderInstance.refreshCache();
    await marketInstance.refreshCache();
    await hitoryInstance.refreshCache();
    await liquidatorInstance.refreshCache();
    await issuerInstance.refreshCache();
    await supplyScheduleInstance.refreshCache();


    // mintFromCoin
    const receipt = await synthxInstance.mintFromCoin({value:10000000000});
    console.log("receipt:", receipt);

    res = await dUSDInstance.balanceOf(accounts[0]);
    console.log(res.toString());
};
