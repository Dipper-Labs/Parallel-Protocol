pragma solidity ^0.5.16;

// Inheritance
import "./Owned.sol";



// Internal references
import "./interfaces/IERC20.sol";

contract Staker is Owned {

    // Available assets which can be staked in the system
    mapping(bytes32 => address) public assets;
    mapping(address => bytes32) public assetsByAddress;

    bytes32 public constant CONTRACT_NAME = "Staker";

    constructor(address _owner) public Owned(_owner){}

    /* ========== VIEWS ========== */
    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](1);
        addresses[0] = CONTRACT_NAME;
    }

    function getAsset(bytes32 name) external view returns (address) {
        return assets[name];
    }

    function requireAsset(bytes32 name) external view returns (address) {
        address assetAddress = assets[name];
        require(assetAddress != address(0), CONTRACT_NAME.concat(': Missing Asset Token ', name));
        return assetAddress;
    }

    function getAssetByAddress(address assetAddress) external view returns (bytes32) {
        return assetsByAddress[assetAddress];
    }

    function getAssets(bytes32[] calldata currencyKeys) external view returns (address[] memory) {
        uint numKeys = currencyKeys.length;
        address[] memory addresses = new address[](numKeys);

        for (uint i = 0; i < numKeys; i++) {
            addresses[i] = assets[currencyKeys[i]];
        }

        return addresses;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _addAsset(bytes32 name, address assetAddress) internal {
        require(assets[name] == address(0), "Asset exists");
        require(assetsByAddress[assetAddress] == bytes32(0), "Asset address already exists");

        assets[name] = assetAddress;
        assetsByAddress[assetAddress] = name;

        emit AssetAdded(name, assetAddress);
    }

    function addAsset(bytes32 name, address assetAddress) external onlyOwner {
        _addAsset(name, assetAddress);
    }

    function _removeAsset(bytes32 name) internal {
        address assetAddress = assets[name];
        require(assetAddress != address(0), "Synth does not exist");
//        require(IERC20(assetAddress).totalSupply() == 0, "asset supply exists");

        // And remove it from the mapping
        delete assetsByAddress[assetAddress];
        delete assets[name];

        emit AssetRemoved(name, assetAddress);
    }

    function removeAsset(bytes32 name) external onlyOwner {
        _removeAsset(name);
    }


    /* ========== EVENTS ========== */

    event AssetAdded(bytes32 name, address assetAddress);
    event AssetRemoved(bytes32 name, address assetAddress);
}
