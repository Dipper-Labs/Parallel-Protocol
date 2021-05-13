const stocksPriceGettor = require('../getStocksPrice');
const tokensPriceGettor = require('../getTokensPrice');

module.exports = function(deployer) {
    deployer
        .then(() => {
            stocksPriceGettor.DoWork();
        })
        .then(() => {
            tokensPriceGettor.DoWork();
        })
}
