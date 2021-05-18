const BTC = artifacts.require("BTC");

module.exports = async function(deployer) {
    await deployer
        .then(() => {
            return deployer.deploy(BTC);
        })
        .then(btcERC20 => {
            console.log('btcERC20 address: ', btcERC20.address);
        });
}
