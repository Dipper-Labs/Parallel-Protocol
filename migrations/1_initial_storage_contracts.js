const Storage = artifacts.require("Storage");
const AddressStorage = artifacts.require("AddressStorage");
const EscrowStorage = artifacts.require("EscrowStorage");
const ExternalStorage = artifacts.require("ExternalStorage");
const LiquidatorStorage = artifacts.require("LiquidatorStorage");
const OracleStorage = artifacts.require("OracleStorage");
const RewardsStorage = artifacts.require("RewardsStorage");
const SettingStorage = artifacts.require("SettingStorage");
const StakerStorage = artifacts.require("StakerStorage");
const TokenStorage = artifacts.require("TokenStorage");
const TraderStorage = artifacts.require("TraderStorage");

const HolderStorage = artifacts.require("HolderStorage");
const ProviderStorage = artifacts.require("ProviderStorage");

module.exports = function (deployer) {
    deployer.deploy(Storage);
    deployer.deploy(AddressStorage);
    deployer.deploy(EscrowStorage);
    deployer.deploy(ExternalStorage);
    deployer.deploy(LiquidatorStorage);
    deployer.deploy(OracleStorage);
    deployer.deploy(RewardsStorage);
    deployer.deploy(SettingStorage);
    deployer.deploy(StakerStorage);
    deployer.deploy(TokenStorage);
    deployer.deploy(TraderStorage);
};
