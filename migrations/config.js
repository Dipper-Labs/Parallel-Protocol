const Web3Utils = require('web3-utils');

const NativeToken = Web3Utils.fromAscii('ETH');
const NativeERC20Addr = '0x84b9b910527ad5c03a9ca831909e21e236ea7b06';

const BTCToken = Web3Utils.fromAscii('BTC');
const BTCERC20Addr = '';

// for foundation and ecology account
const FoundationAddr = '';
const EcologyAddr = '';

// contractName_configurationName
const Setting_LiquidationDelay = 36000;
const Setting_MintPeriodDuration = 3600*24; // second
const AssetPrice_MaxDelayTime = 60 * 30; //second

// for assets config
const CollateralRateBTC = Web3Utils.toWei('3', 'ether');
const LiquidationRateBTC = Web3Utils.toWei('1', 'ether');
const TradingFeeRateBTC = Web3Utils.toWei('2', 'milliether');

const CollateralRateETH = Web3Utils.toWei('3', 'ether');
const LiquidationRateETH = Web3Utils.toWei('1', 'ether');
const TradingFeeRateETH = Web3Utils.toWei('2', 'milliether');

const CollateralRateBNB = Web3Utils.toWei('3', 'ether');
const LiquidationRateBNB = Web3Utils.toWei('1', 'ether');
const TradingFeeRateBNB = Web3Utils.toWei('2', 'milliether');

exports.NativeToken = NativeToken;
exports.NativeERC20Addr = NativeERC20Addr;
exports.BTCToken = BTCToken;
exports.BTCERC20Addr = BTCERC20Addr;
exports.FoundationAddr = FoundationAddr;
exports.EcologyAddr = EcologyAddr;
exports.LiquidationDelay = Setting_LiquidationDelay;
exports.MintPeriodDuration = Setting_MintPeriodDuration;
exports.MaxDelayTime = AssetPrice_MaxDelayTime;

exports.CollateralRateBTC = CollateralRateBTC;
exports.LiquidationRateBTC = LiquidationRateBTC;
exports.TradingFeeRateBTC = TradingFeeRateBTC;
exports.CollateralRateETH = CollateralRateETH;
exports.LiquidationRateETH = LiquidationRateETH;
exports.TradingFeeRateETH = TradingFeeRateETH;
exports.CollateralRateBNB = CollateralRateBNB;
exports.LiquidationRateBNB = LiquidationRateBNB;
exports.TradingFeeRateBNB = TradingFeeRateBNB;