// for synthx.initialize
const nativeToken = 'ETH';

// for resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii(nativeToken), fakeERC20Addr);
const fakeERC20Addr = '0x84b9b910527ad5c03a9ca831909e21e236ea7b06';

// for foundation and ecology account
const foundationAddr = '';
const ecologyAddr = '';

// contractName_configurationName
const setting_LiquidationDelay = 36000;
const setting_MintPeriodDuration = 3600*24; // second
const assetPrice_MaxDelayTime = 60 * 30; //second


exports.nativeToken = nativeToken;
exports.fakeERC20Addr = fakeERC20Addr;
exports.foundationAddr = foundationAddr;
exports.ecologyAddr = ecologyAddr;
exports.liquidationDelay = setting_LiquidationDelay;
exports.mintPeriodDuration = setting_MintPeriodDuration;
exports.maxDelayTime = assetPrice_MaxDelayTime;
