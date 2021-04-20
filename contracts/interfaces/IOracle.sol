pragma solidity ^0.5.17;

interface IOracle {
    function getPrice(bytes32 asset)
        external
        view
        returns (
            uint256 round,
            uint256 price,
            uint256 time
        );

    function getPrice(bytes32 asset, uint256 round) external view returns (uint256 price, uint256 time);
}
