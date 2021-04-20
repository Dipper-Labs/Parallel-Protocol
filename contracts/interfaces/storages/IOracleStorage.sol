pragma solidity ^0.5.17;

interface IOracleStorage {
    struct Price {
        uint256 price;
        uint256 time;
    }

    function setRound(bytes32 asset, uint256 round) external;

    function getRound(bytes32 asset) external view returns (uint256);

    function setPrice(bytes32 asset, uint256 price) external;

    function getPrice(bytes32 asset, uint256 round) external view returns (uint256 price, uint256 time);
}
