const Web3Utils = require('web3-utils');

const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");

const Setting = artifacts.require("Setting");
const SettingStorage = artifacts.require("SettingStorage");

const Resolver = artifacts.require("Resolver");

const Issuer = artifacts.require("Issuer");

const Escrow = artifacts.require("Escrow");
const EscrowStorage = artifacts.require("EscrowStorage");

const History = artifacts.require("History");

const Liquidator = artifacts.require("Liquidator");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");

const SynthxToken = artifacts.require("SynthxToken");

const Synthx = artifacts.require("Synthx");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(Storage);
    await deployer.deploy(AddressStorage);
    await deployer.deploy(Setting).then(async function() {
        await deployer.deploy(SettingStorage, Setting.address);
    });

    const resolverInstance = await deployer.deploy(Resolver);

    await deployer.deploy(Escrow, Resolver.address).then(async function() {
        await deployer.deploy(EscrowStorage, Escrow.address);
    });


    await deployer.deploy(Issuer, Resolver.address);
    /*
        CONTRACT_ESCROW,
        CONTRACT_STAKER,
        CONTRACT_ASSET_PRICE,
        CONTRACT_SETTING,
        CONTRACT_ISSUER,
        CONTRACT_TRADER,
        CONTRACT_SYNTHX_TOKEN,
        CONTRACT_MARKET,
        CONTRACT_HISTORY,
        CONTRACT_LIQUIDATOR
     */
    await resolverInstance.setAddress(Web3Utils.fromAscii('Escrow'), Escrow.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Staker'), Staker.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('AssetPrice'), AssetPrice.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Setting'), Setting.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Issuer'), Issuer.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Trader'), Trader.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('SynthxToken'), SynthxToken.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Market'), Market.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('History'), History.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Liquidator'), Liquidator.address);

    const synthxTokenInstance = await deployer.deploy(SynthxToken);
    await synthxTokenInstance.initialize(Resolver.address);

    await deployer.deploy(History, resolverInstance.address);

    await deployer.deploy(Liquidator, Resolver.address).then(async function() {
        await deployer.deploy(LiquidatorStorage, Liquidator.address);
    });

    const synthxInstance = await deployer.deploy(Synthx);
    synthxInstance.initialize(Resolver.address, Web3Utils.fromAscii('ETH'));
    const owner = await synthxInstance.owner();
    console.log("synthx owner:", owner);

    // mintFromCoin
    const receipt = await synthxInstance.mintFromCoin();
    console.log("receipt:", receipt);
};
