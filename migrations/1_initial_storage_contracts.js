const Setting = artifacts.require("Setting");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(Setting);
};
