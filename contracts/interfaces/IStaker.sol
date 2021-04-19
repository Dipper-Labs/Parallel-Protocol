pragma solidity >=0.4.24;

interface IStaker {
    // Views
    function getAsset(bytes32 name) external view returns (address);
    function requireAsset(bytes32 name) external view returns (address);
    function getAssetByAddress(address assetAddress) external view returns (bytes32);
}
