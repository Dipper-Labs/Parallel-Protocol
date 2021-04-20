pragma solidity ^0.5.17;

interface ISynbitOracle {
    function setPrice(bytes32 asset, uint256 price) external;

    function setPrices(bytes32[] calldata assets, uint256[] calldata prices) external;

    event AssetPriceChanged(bytes32 indexed asset, uint256 indexed round, uint256 previousValue, uint256 newValue);
}
