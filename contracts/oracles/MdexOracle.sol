pragma solidity ^0.5.17;

import '../storages/AddressStorage.sol';
import '../interfaces/IOracle.sol';
import '../interfaces/oracles/IMdex.sol';

contract MdexOracle is AddressStorage, IOracle {
    bytes32 private ASSETS = 'Assets';

    event IMdexPairChanged(address indexed caller, bytes32 indexed asset, address previousValue, address newValue);
    event IMdexPairRemoved(address indexed caller, bytes32 indexed asset, address previousValue);

    constructor() public {
        contractName = 'MdexOracle';
    }

    function setPair(
        bytes32 asset,
        address assetAddress,
        address pair
    ) external onlyOwner {
        emit IMdexPairChanged(msg.sender, asset, getAddressValue(asset), pair);
        setAddressValue(asset, pair);
        setAddressValue(ASSETS, asset, assetAddress);
    }

    function removePair(bytes32 asset) external onlyOwner {
        emit IMdexPairRemoved(msg.sender, asset, getAddressValue(asset));
        removeAddressValue(asset);
        removeAddressValue(ASSETS, asset);
    }

    function getPair(bytes32 asset) public view returns (address) {
        return getAddressValue(asset);
    }

    function getPrice(bytes32 asset)
        public
        view
        returns (
            uint256 round,
            uint256 price,
            uint256 time
        )
    {
        address pair = getPair(asset);
        if (pair == address(0)) return (0, 0, 0);
        uint256 assetPrice = IMdex(pair).price(getAddressValue(ASSETS, asset), 1 ether);
        return (now, assetPrice, now);
    }

    function getPrice(bytes32 asset, uint256) external view returns (uint256 price, uint256 time) {
        time = now;
        (, price, ) = getPrice(asset);
    }
}
