const contractAddrs = require('../finalContractAddrs.json')

const AssetPrice = artifacts.require("AssetPrice");

// truffle migrate --network local --skip-dry-run -f 104 --maxDelayTime=360000
const args = require('minimist')(process.argv.slice(2));

module.exports = async function(deployer) {

    const assetPrice = await AssetPrice.at(contractAddrs.assetPrice);

    await deployer
        .then(() => {
            return assetPrice.setMaxDelayTime(args['maxDelayTime']);
        })
        .then((receipt) => {
            console.log('receipt: ', receipt);
            return assetPrice.maxDelayTime();
        })
        .then((maxDelayTime) => {
            console.log("maxDelayTime: ", maxDelayTime);
        })
}