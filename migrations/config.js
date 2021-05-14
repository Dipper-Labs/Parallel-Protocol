const Web3Utils = require('web3-utils');

const NativeToken = Web3Utils.fromAscii('ETH');
const NativeERC20Addr = '0x84b9b910527ad5c03a9ca831909e21e236ea7b06';

const BTCToken = Web3Utils.fromAscii('BTC');
const BTCERC20Addr = '0xe90cec8332a17361f427b1b8ffa5270b39b21076';

// for foundation and ecology account
const FoundationAddr = '0xdBdBaD81F21eb97b17B67FD31c1c1667Dc5dEeF8';
const EcologyAddr = '0xdBdBaD81F21eb97b17B67FD31c1c1667Dc5dEeF8';

// contractName_configurationName
const Setting_LiquidationDelay = 36000;
const Setting_MintPeriodDuration = 3600*24; // second
const AssetPrice_MaxDelayTime = 60 * 30; //second


exports.NativeToken = NativeToken;
exports.NativeERC20Addr = NativeERC20Addr;
exports.BTCToken = BTCToken;
exports.BTCERC20Addr = BTCERC20Addr;
exports.FoundationAddr = FoundationAddr;
exports.EcologyAddr = EcologyAddr;
exports.LiquidationDelay = Setting_LiquidationDelay;
exports.MintPeriodDuration = Setting_MintPeriodDuration;
exports.MaxDelayTime = AssetPrice_MaxDelayTime;
