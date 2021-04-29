const Web3Utils = require('web3-utils');
const Web3 = require('web3');
var Contract = require('web3-eth-contract');
const Oracle = require("../build/contracts/SynthxOracle.json");

Contract.setProvider('https://data-seed-prebsc-1-s1.binance.org:8545');

const oracle = new Contract(Oracle.abi, '0xc8FcD5912E6eb90255e26D88339C246a7C4f9AbC');

const ethPriceKey = Web3Utils.fromAscii('ETH');
const bnbPriceKey = Web3Utils.fromAscii('BNB');
const dipPriceKey = Web3Utils.fromAscii('DIP');
const btcPriceKey = Web3Utils.fromAscii('BTC');
const dTslaPriceKey = Web3Utils.fromAscii('dTSLA');
const dApplePriceKey = Web3Utils.fromAscii('dAPPLE');

setInterval(async ()=> {
    oracle.methods.getPrice(ethPriceKey).call({from:null}, (error, result) => {
        console.log(result.round.toString());
        console.log(result.price.toString());
        console.log(result.time.toString());
    });
}, 1000);
