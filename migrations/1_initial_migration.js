const ContractProxy = artifacts.require("Proxy");
const ContractTokenState = artifacts.require("TokenState");
const ContractExternStateToken = artifacts.require("ExternStateToken");
const ContractSynthetix = artifacts.require("Synthetix");
const ContractIssuer = artifacts.require("Issuer");
const ContractSafeDecimalMath = artifacts.require("SafeDecimalMath");

module.exports = async function (deployer) {
  var owner = "0x5b0B5A7e5790668956D5360FFe64f658ce1d9d9E";
  var nilAddress = "0x2c3Af4800d0ebfE733Ce904d15b1647229aF574E"
  var associatedContractAddr = "0x2c3Af4800d0ebfE733Ce904d15b1647229aF574E";
  var devAddress = "0x2c3Af4800d0ebfE733Ce904d15b1647229aF574E"
  var echAddress = "0x2c3Af4800d0ebfE733Ce904d15b1647229aF574E"

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
  // await deployer.deploy(ContractSynthetix, Proxy.address, TokenState.address, owner, totalSupply, owner, devAddress, echAddress);
  // const Synthetix = await ContractSynthetix.deployed();

  // Issuer
  // constructor(address _owner, address _resolver)
  ContractIssuer.link('SafeDecimalMath', SafeDecimalMath.address);
  await deployer.deploy(ContractIssuer, owner, owner);
  const Issuer = await ContractIssuer.deployed();
};
