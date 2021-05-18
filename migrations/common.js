const Web3Utils = require('web3-utils');

const AssetTypeStake = Web3Utils.fromAscii('Stake');
const AssetTypeSynth = Web3Utils.fromAscii('Synth');

const sDIP = Web3Utils.fromAscii('SynthxToken');
const dToken = Web3Utils.fromAscii('SynthxDToken');
const Synth_dUSD = Web3Utils.fromAscii('dUSD');
const Synth_dTSLA = Web3Utils.fromAscii('dTSLA');
const Synth_dAAPL = Web3Utils.fromAscii('dAAPL');



// exports
exports.AssetTypeStake = AssetTypeStake;
exports.AssetTypeSynth = AssetTypeSynth;

exports.sDIP = sDIP;
exports.dToken = dToken;
exports.Synth_dUSD = Synth_dUSD;
exports.Synth_dTSLA = Synth_dTSLA;
exports.Synth_dAAPL = Synth_dAAPL;