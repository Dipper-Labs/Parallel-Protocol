// for synthx.initialize
const nativeToken = 'ETH';

// for resolver.addAsset(Web3Utils.fromAscii('Stake'), Web3Utils.fromAscii(nativeToken), fakeERC20Addr);
const fakeERC20Addr = '0x84b9b910527ad5c03a9ca831909e21e236ea7b06';

// for setting.setLiquidationDelay
const liquidationDelay = 36000;

// for setting.setMintPeriodDuration
const mintPeriodDuration = 3600*24; // second

// for foundation and ecology account
const foundationAddr = '';
const ecologyAddr = '';


exports.nativeToken = nativeToken;
exports.fakeERC20Addr = fakeERC20Addr;
exports.liquidationDelay = liquidationDelay;
exports.mintPeriodDuration = mintPeriodDuration;
exports.foundationAddr = foundationAddr;
exports.ecologyAddr = ecologyAddr;
