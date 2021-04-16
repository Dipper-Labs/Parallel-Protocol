const ContractProxy = artifacts.require("Proxy");
const ContractTokenState = artifacts.require("TokenState");
const ContractExternStateToken = artifacts.require("ExternStateToken");
const ContractSynthetix = artifacts.require("Synthetix");
const ContractIssuer = artifacts.require("Issuer");
const ContractSafeDecimalMath = artifacts.require("SafeDecimalMath");
const ContractOwned = artifacts.require("Owned");
const ContractMixinSystemSettings =artifacts.require("MixinSystemSettings");
const ContractReadProxy = artifacts.require("ReadProxy");
const ContractAddressResolver = artifacts.require("AddressResolver")
const ContractExchanger = artifacts.require("Exchanger")
const ContractSystemStatus = artifacts.require("SystemStatus")


module.exports = async function (deployer) {
  var owner = "0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC";
  var nilAddress = "0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC"
  var associatedContractAddr = "0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC";
  var devAddress = "0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC"
  var echAddress = "0xEa3ED7E36aBb9AC0Adb61c58359Be48Ad87C3bCC"

  // SafeDecimalMath
  await deployer.deploy(ContractSafeDecimalMath);
  const SafeDecimalMath = await ContractSafeDecimalMath.deployed();
  console.log("SafeDecimalMath:", SafeDecimalMath.address)

  // Proxy
  await deployer.deploy(ContractProxy, owner);
  const Proxy = await ContractProxy.deployed();

  // TokenState
  await deployer.deploy(ContractTokenState, owner, nilAddress);
  const TokenState = await ContractTokenState.deployed();
  // setAssociatedContract
  const receipt = await TokenState.setAssociatedContract(associatedContractAddr);
  // console.log(receipt)
  // const ownerOfContract = await TokenState.owner();
  // console.log("owner:", ownerOfContract)

  // ExternStateToken
  /*
    address payable _proxy,
        TokenState _tokenState,
        string memory _name,
        string memory _symbol,
        uint _totalSupply,
        uint8 _decimals,
        address _owner
   */
  let BigNumber=require('bignumber.js');
  let totalSupply=new BigNumber('1000000000000000000000000000');
  // var totalSupply = 100000000000000;
  var decimal = 6;
  await deployer.deploy(ContractExternStateToken, Proxy.address, TokenState.address, "SDIP", "SDIP", totalSupply, decimal, owner);
  const ExternStateToken = await ContractExternStateToken.deployed();
  const symbol = await ExternStateToken.symbol();
  console.log("symbol:", symbol)
  const rTotalSupply = await ExternStateToken.totalSupply()
  console.log("totalSupply:", rTotalSupply.toString())


  /////////////////////////////////////////// SystemStatus
  await deployer.deploy(ContractSystemStatus, owner);
  const SystemStatus = await ContractSystemStatus.deployed();


  //////////////////////////////////////////// Synthetix
  /*
      constructor(
        address payable _proxy, // ProxyERC20
        TokenState _tokenState, // TokenState
        address _owner,
        uint _totalSupply,
        address _resolver,
        address _dev,
        address _eco
    )
   */
  // await deployer.deploy(ContractAddressResolver, owner);
  // const AddressResolver = await ContractAddressResolver.deployed();
  // // ProxyErc20
  // await deployer.deploy(ContractReadProxy, owner);
  // const AddressResolver = await ContractReadProxy.deployed();
  //
  // await deployer.deploy(ContractSynthetix, Proxy.address, TokenState.address, owner, totalSupply, AddressResolver.address, devAddress, echAddress);
  // const Synthetix = await ContractSynthetix.deployed();
  //
  // ///////////////////////////////// Issuer
  // ReadProxy
  await deployer.deploy(ContractReadProxy, owner);
  const ReadProxy = await ContractReadProxy.deployed();
  // AddressResolver
  await deployer.deploy(ContractAddressResolver, ReadProxy.address);
  const AddressResolver2 = await ContractAddressResolver.deployed();
  // Issuer
  // constructor(address _owner, address _resolver)
  ContractIssuer.link('SafeDecimalMath', SafeDecimalMath.address);
  await deployer.deploy(ContractIssuer, owner, AddressResolver2.address);
  const Issuer = await ContractIssuer.deployed();





  // // AddressResolver
  // await deployer.deploy(ContractAddressResolver, owner);
  // const AddressResolver3 = await ContractAddressResolver.deployed();
  // // Exchange
  // ContractExchanger.link('SafeDecimalMath', SafeDecimalMath.address);
  // await deployer.deploy(ContractExchanger, owner, AddressResolver3.address);
  // const Exchanger = await ContractExchanger.deployed();
};
