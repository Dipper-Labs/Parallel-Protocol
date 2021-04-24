const Web3Utils = require('web3-utils');

const Migrations = artifacts.require("Migrations");

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
const SynthxOracle = artifacts.require("SynthxOracle");
const Trader = artifacts.require("Trader");
const Market = artifacts.require("Market");
const Special = artifacts.require("Special");
const SupplySchedule = artifacts.require("SupplySchedule");
const Stats = artifacts.require("Stats");
const Synthx = artifacts.require("Synthx");

const Synth = artifacts.require("Synth");
const SynthxToken = artifacts.require("SynthxToken");   // sDIP
const SynthxDToken = artifacts.require("SynthxDToken"); // DToken

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(Migrations);

    // deploy contracts
    const setting = await deployer.deploy(Setting);
    const resolver = await deployer.deploy(Resolver);
    const escrow = await deployer.deploy(Escrow, Resolver.address);
    const issuer = await deployer.deploy(Issuer, Resolver.address);

    const hitory = await deployer.deploy(History, Resolver.address);
    const liquidator = await deployer.deploy(Liquidator, Resolver.address);
    const staker = await deployer.deploy(Staker, Resolver.address);
    const assetPrice = await deployer.deploy(AssetPrice);
    const oracle = await deployer.deploy(SynthxOracle);
    const trader = await deployer.deploy(Trader, Resolver.address);
    const market = await deployer.deploy(Market, Resolver.address);
    const special = await deployer.deploy(Special, Resolver.address);
    const supplySchedule = await deployer.deploy(SupplySchedule, Resolver.address, 0, 0);
    const stats = await deployer.deploy(Stats, Resolver.address);
    const synthx = await deployer.deploy(Synthx);
    synthx.initialize(Resolver.address, Web3Utils.fromAscii('ETH'));

    // deploy storages
    await deployer.deploy(Storage);
    await deployer.deploy(AddressStorage);
    await deployer.deploy(SettingStorage, Setting.address);
    await deployer.deploy(EscrowStorage, Escrow.address);
    await deployer.deploy(IssuerStorage, Issuer.address);
    await deployer.deploy(LiquidatorStorage, Liquidator.address);
    await deployer.deploy(StakerStorage, Staker.address);
    await deployer.deploy(OracleStorage, SynthxOracle.address);
    await deployer.deploy(TraderStorage, Trader.address);

    // setup storage of contract
    await setting.setStorage(SettingStorage.address);
    await escrow.setStorage(EscrowStorage.address);
    await issuer.setStorage(IssuerStorage.address);
    await liquidator.setStorage(LiquidatorStorage.address)
    await staker.setStorage(StakerStorage.address);
    await oracle.setStorage(OracleStorage.address);
    await trader.setStorage(TraderStorage.address);

    //////// deploy tokens ////////
    const dUSD = await deployer.deploy(Synth);
    const synthxToken = await deployer.deploy(SynthxToken);
    const synthxDToken = await deployer.deploy(SynthxDToken, Resolver.address);
    const dTSLA = await deployer.deploy(Synth);
    const dAPPLE = await deployer.deploy(Synth);

    //////// deploy token storages ////////
    const dUSDStorage = await deployer.deploy(TokenStorage, dUSD.address);
    const synthxTokenStorage = await deployer.deploy(TokenStorage, synthxToken.address);
    const synthxDTokenStorage = await deployer.deploy(TokenStorage, synthxDToken.address);
    const dTSLAStorage = await deployer.deploy(TokenStorage, dTSLA.address);
    const dAPPLEStorage = await deployer.deploy(TokenStorage, dAPPLE.address);

    //////// setup token storages ////////
    await dUSD.setStorage(dUSDStorage.address);
    await synthxToken.setStorage(synthxTokenStorage.address);
    await synthxDToken.setStorage(synthxDTokenStorage.address);
    await dTSLA.setStorage(dTSLAStorage.address);
    await dAPPLE.setStorage(dAPPLEStorage.address);

    //////// tokens initialize ////////
    // resolver.setAddress should be done before tokens initialize
    await resolver.setAddress(Web3Utils.fromAscii('Issuer'), Issuer.address);

    await dUSD.initialize(Issuer.address, "dUSD", "dUSD", Web3Utils.fromAscii('erc20'));
    await synthxToken.initialize(Resolver.address);
    await synthxDToken.initialize();
    await dTSLA.initialize(Issuer.address, "dTSLA", "dTSLA", Web3Utils.fromAscii('2'));
    await dAPPLE.initialize(Issuer.address, "dAPPLE", "dAPPLE", Web3Utils.fromAscii('2'));
    
    // setup asset price
    oracle.setPrice(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2000', 'ether'));
    oracle.setPrice(Web3Utils.fromAscii('BTC'), Web3Utils.toWei('50000', 'ether'));
    oracle.setPrice(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('750', 'ether'));
    oracle.setPrice(Web3Utils.fromAscii('dAPPLE'), Web3Utils.toWei('150', 'ether'));

    // setup oracle
    assetPrice.setOracle(Web3Utils.fromAscii('ETH'), oracle.address);
    assetPrice.setOracle(Web3Utils.fromAscii('BTC'), oracle.address);
    assetPrice.setOracle(Web3Utils.fromAscii('dTSLA'), oracle.address);
    assetPrice.setOracle(Web3Utils.fromAscii('dAPPLE'), oracle.address);

    await resolver.setAddress(Web3Utils.fromAscii('Escrow'), Escrow.address);
    await resolver.setAddress(Web3Utils.fromAscii('Staker'), Staker.address);
    await resolver.setAddress(Web3Utils.fromAscii('AssetPrice'), AssetPrice.address);
    await resolver.setAddress(Web3Utils.fromAscii('Setting'), Setting.address);
    await resolver.setAddress(Web3Utils.fromAscii('Oracle'), oracle.address);
    await resolver.setAddress(Web3Utils.fromAscii('Trader'), Trader.address);
    await resolver.setAddress(Web3Utils.fromAscii('Market'), Market.address);
    await resolver.setAddress(Web3Utils.fromAscii('History'), History.address);
    await resolver.setAddress(Web3Utils.fromAscii('Liquidator'), Liquidator.address);
    await resolver.setAddress(Web3Utils.fromAscii('SupplySchedule'), SupplySchedule.address);
    await resolver.setAddress(Web3Utils.fromAscii('Team'), accounts[0]); // Team address
    await resolver.setAddress(Web3Utils.fromAscii('Synthx'), Synthx.address);
    await resolver.setAddress(Web3Utils.fromAscii('SynthxToken'), SynthxToken.address);
    await resolver.setAddress(Web3Utils.fromAscii('SynthxDToken'), SynthxDToken.address);

    await resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii('ETH'), accounts[0]);
    await resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dUSD'), dUSD.address);
    await resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dTSLA'), dTSLA.address);
    await resolver.addAsset(Web3Utils.fromAscii('Synth'), Web3Utils.fromAscii('dAPPLE'), dAPPLE.address);

    // refresh caches
    await synthx.refreshCache();
    await escrow.refreshCache();
    await staker.refreshCache();
    await trader.refreshCache();
    await market.refreshCache();
    await hitory.refreshCache();
    await liquidator.refreshCache();
    await issuer.refreshCache();
    await supplySchedule.refreshCache();
    await stats.refreshCache();
    await synthxDToken.refreshCache();

    await setting.setCollateralRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'ether'));
    await setting.setLiquidationRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('1', 'ether'));
    await setting.setLiquidationDelay(36000);
    await setting.setTradingFeeRate(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2', 'milliether'));
    await setting.setMintPeriodDuration(1); // second

    let res = await setting.getCollateralRate(Web3Utils.fromAscii('ETH'));
    console.log("CollateralRate: ", Web3Utils.fromWei(res, 'ether'));
    console.log("contracts deployment finished\n\n")

    ///////////////////////////////////////////////////////////////////////////////////////
    console.log("-------- mint synths -------- ");
    receipt = await synthx.mintFromCoin({value:Web3Utils.toWei('20', 'ether')});

    bal = await dUSD.balanceOf(accounts[0]);
    console.log("dUSD balance:", Web3Utils.fromWei(bal, 'ether'));
    dTokenBal = await synthxDToken.balanceOf(accounts[0]);
    console.log("dToken balance:", Web3Utils.fromWei(dTokenBal, 'ether'));
    col = await stats.getTotalCollateral(accounts[0])
    console.log("totalDebt:", Web3Utils.fromWei(col.totalDebt, 'ether'));


    console.log("\n-------- burn synths -------- ");
    await new Promise(r => setTimeout(r, 2000)); // sleep
    await synthx.burn(Web3Utils.fromAscii('ETH'), Web3Utils.toWei('2000', 'ether'));

    bal = await dUSD.balanceOf(accounts[0]);
    console.log("dUSD balance:", Web3Utils.fromWei(bal, 'ether'));
    dTokenBal = await synthxDToken.balanceOf(accounts[0]);
    console.log("dToken balance:", Web3Utils.fromWei(dTokenBal, 'ether'));
    col = await stats.getTotalCollateral(accounts[0])
    console.log("totalDebt:", Web3Utils.fromWei(col.totalDebt, 'ether'));

    res = await stats.getRewards(accounts[0]);
    console.log("rewards: ", Web3Utils.fromWei(res, 'ether'))

    res = await stats.getWithdrawable(accounts[0]);
    console.log("getWithdrawable:", Web3Utils.fromWei(res, 'ether'));

    console.log("-------- claim rewards -------- ");
    await synthx.claimReward();
    bal = await synthxToken.balanceOf(accounts[0]);
    console.log("synthx balance:", Web3Utils.fromWei(bal, 'ether'));

    console.log("-------- trade -------- ");
    ///////////////  trade
    // dUSD => dTSLA
    await synthx.trade(Web3Utils.fromAscii('dUSD'), Web3Utils.toWei('10000', 'ether'),  Web3Utils.fromAscii('dTSLA'));
    bal = await dTSLA.balanceOf(accounts[0]);
    console.log("dTSLA balance:", Web3Utils.fromWei(bal, 'ether'));

    // dTSLA => dAPPLE
    await synthx.trade(Web3Utils.fromAscii('dTSLA'), Web3Utils.toWei('13', 'ether'),  Web3Utils.fromAscii('dAPPLE'));
    bal = await dAPPLE.balanceOf(accounts[0]);
    console.log("dAPPLE balance:", Web3Utils.fromWei(bal, 'ether'));

    // get synth asset
    res = await stats.getAssets(Web3Utils.fromAscii('Synth'), accounts[0]);
    console.log("synth assets:", res)
    // get stake asset
    res = await stats.getAssets(Web3Utils.fromAscii('Stake'), accounts[0]);
    console.log("stake assets:", res)
    // get vaullts
    res = await stats.getVaults(accounts[0]);
    console.log("getVaults:", res)

    // getTotalCollateral
    res = await stats.getTotalCollateral(accounts[0]);
    console.log("getTotalCollateral:", res)
};
