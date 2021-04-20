pragma solidity ^0.5.17;

import '../storages/AddressStorage.sol';
import '../interfaces/IOracle.sol';
import '../interfaces/oracles/IChainLinkAggregator.sol';

contract ChainLinkOracle is AddressStorage, IOracle {
    event AggregatorChanged(address indexed caller, bytes32 indexed asset, address previousValue, address newValue);
    event AggregatorRemoved(address indexed caller, bytes32 indexed asset, address previousValue);

    constructor() public {
        contractName = 'ChainLinkOracle';
    }

    function setAggregator(bytes32 asset, address aggregator) external onlyOwner {
        emit AggregatorChanged(msg.sender, asset, getAddressValue(asset), aggregator);
        setAddressValue(asset, aggregator);
    }

    function removeAggregator(bytes32 asset) external onlyOwner {
        emit AggregatorRemoved(msg.sender, asset, getAddressValue(asset));
        removeAddressValue(asset);
    }

    function getAggregator(bytes32 asset) public view returns (address) {
        return getAddressValue(asset);
    }

    function getPrice(bytes32 asset)
        external
        view
        returns (
            uint256 round,
            uint256 price,
            uint256 time
        )
    {
        address aggregator = getAggregator(asset);
        if (aggregator == address(0)) return (0, 0, 0);
        (uint256 roundId, int256 oraclePrice, , uint256 oracleTime, ) =
            IChainLinkAggregator(aggregator).latestRoundData();
        return (roundId, uint256(oraclePrice * 1e10), oracleTime);
    }

    function getPrice(bytes32 asset, uint256 round) external view returns (uint256 price, uint256 time) {
        address aggregator = getAggregator(asset);
        if (aggregator == address(0)) return (0, 0);
        (, int256 oraclePrice, , uint256 oracleTime, ) = IChainLinkAggregator(aggregator).getRoundData(uint80(round));
        return (uint256(oraclePrice * 1e10), oracleTime);
    }
}
