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

    const synthxInstance = await deployer.deploy(Synthx);
    synthxInstance.initialize(Resolver.address, synthxTokenInstance.address);
};
