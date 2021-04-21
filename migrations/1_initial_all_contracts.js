const Web3Utils = require('web3-utils');

const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");

const Setting = artifacts.require("Setting");
const SettingStorage = artifacts.require("SettingStorage");

const Resolver = artifacts.require("Resolver");

const Issuer = artifacts.require("Issuer");
const Holder = artifacts.require("Holder");

const Escrow = artifacts.require("Escrow");
const EscrowStorage = artifacts.require("EscrowStorage");

const History = artifacts.require("History");

const Liquidator = artifacts.require("Liquidator");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");

const Staker = artifacts.require("Staker");
const StakerStorage = artifacts.require("StakerStorage");

const AssetPrice = artifacts.require("AssetPrice");

const Trader = artifacts.require("Trader");
const TraderStorage = artifacts.require("TraderStorage");

const Provider = artifacts.require("Provider");
const ProviderStorage = artifacts.require("ProviderStorage");

const Market = artifacts.require("Market");
const Special = artifacts.require("Special");

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
    await deployer.deploy(Holder, Resolver.address);

    await resolverInstance.setAddress(Web3Utils.fromAscii('Issuer'), Issuer.address);
    await resolverInstance.setAddress(Web3Utils.fromAscii('Holder'), Holder.address);

    const synthxTokenInstance = await deployer.deploy(SynthxToken);
    await synthxTokenInstance.initialize(Resolver.address);

    await deployer.deploy(History, resolverInstance.address);

    await deployer.deploy(History, resolverInstance.address);

    await deployer.deploy(Liquidator, Resolver.address).then(async function() {
        await deployer.deploy(LiquidatorStorage, Liquidator.address);
    });

    await deployer.deploy(Staker, Resolver.address).then(async function() {
        await deployer.deploy(StakerStorage, Staker.address);
    });

    await deployer.deploy(AssetPrice);

    await deployer.deploy(Trader, Resolver.address).then(async function() {
        await deployer.deploy(TraderStorage, Trader.address);
    });

    await deployer.deploy(Provider, Resolver.address).then(async function() {
        await deployer.deploy(ProviderStorage, Provider.address);
    });

    await deployer.deploy(Market, Resolver.address);

    await deployer.deploy(Special, Resolver.address);

    const synthxInstance = await deployer.deploy(Synthx);
    synthxInstance.initialize(Resolver.address, synthxTokenInstance.address);
};
