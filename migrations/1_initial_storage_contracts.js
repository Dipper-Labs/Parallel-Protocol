//basic contracts
const Setting = artifacts.require("Setting");
const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");
const Resolver = artifacts.require("Resolver");

const Escrow = artifacts.require("Escrow");
const EscrowStorage = artifacts.require("EscrowStorage");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(Setting);
    await deployer.deploy(Storage);
    await deployer.deploy(AddressStorage);
    await deployer.deploy(Resolver).then(async function() {
        await deployer.deploy(Escrow, Resolver.address).then(async function() {
            await deployer.deploy(EscrowStorage, Escrow.address);
        });
    })
};
