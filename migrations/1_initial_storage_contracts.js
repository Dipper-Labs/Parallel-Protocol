const Setting = artifacts.require("Setting");
const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(Setting);
    deployer.deploy(Storage);
    deployer.deploy(AddressStorage);
};
