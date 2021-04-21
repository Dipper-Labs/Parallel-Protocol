const Setting = artifacts.require("Setting");
const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");
const Resolver = artifacts.require("Resolver");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(Setting);
    deployer.deploy(Storage);
    deployer.deploy(AddressStorage);
    deployer.deploy(Resolver);
};
