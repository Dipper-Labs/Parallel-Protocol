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

  // ContractReadProxy
  await deployer.deploy(ContractReadProxy, owner);
  const ReadProxy = await ContractReadProxy.deployed();

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
  var totalSupply = 100000000000000;
  var decimal = 6;
  await deployer.deploy(ContractExternStateToken, Proxy.address, TokenState.address, "SDIP", "SDIP", totalSupply, decimal, owner);
  const ExternStateToken = await ContractExternStateToken.deployed();
  const symbol = await ExternStateToken.symbol();
  console.log("symbol:", symbol)

  // Synthetix
  /*
      constructor(
        address payable _proxy,
        TokenState _tokenState,
        address _owner,
        uint _totalSupply,
        address _resolver,
        address _dev,
        address _eco
    )
   */
  var resolver = owner;
  await deployer.deploy(ContractAddressResolver, owner);
  const AddressResolver = await ContractAddressResolver.deployed();
  await deployer.deploy(ContractSynthetix, Proxy.address, TokenState.address, owner, totalSupply, AddressResolver.address, devAddress, echAddress);
  const Synthetix = await ContractSynthetix.deployed();
  return;

  // AddressResolver
  // await deployer.deploy(ContractAddressResolver, owner);
  // const AddressResolver = await ContractAddressResolver.deployed();

  // Issuer
  // constructor(address _owner, address _resolver)
  // ContractIssuer.link('SafeDecimalMath', SafeDecimalMath.address);
  // await deployer.deploy(ContractIssuer, owner, owner);
  // const Issuer = await ContractIssuer.deployed();

  // Exchange
  // ContractExchanger.link('SafeDecimalMath', SafeDecimalMath.address);
  // await deployer.deploy(ContractExchanger, owner, owner);
  // const Exchanger = await ContractExchanger.deployed();
};
