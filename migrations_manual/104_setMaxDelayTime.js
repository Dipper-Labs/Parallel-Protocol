const contractAddrs = require('../finalContractAddrs.json')

const AssetPrice = artifacts.require("AssetPrice");

module.exports = async function(deployer, network, accounts) {

    const assetPrice = await AssetPrice.at(contractAddrs.assetPrice);

    await deployer
        .then(() => {
            return assetPrice.setMaxDelayTime(360000);
        })
        .then((receipt) => {
            console.log('receipt: ', receipt);
            return assetPrice.maxDelayTime();
        })
        .then((maxDelayTime) => {
            console.log("maxDelayTime: ", maxDelayTime);
        })
}