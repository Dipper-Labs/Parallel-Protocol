pragma solidity ^0.5.17;

interface ITokenStorage {
    function setAllowance(
        address key,
        address field,
        uint256 value
    ) external;

    function getAllowance(address key, address field) external view returns (uint256);

    function incrementUint(
        bytes32 key,
        address field,
        uint256 value
    ) external returns (uint256);

    function decrementUint(
        bytes32 key,
        address field,
        uint256 value,
        string calldata errorMessage
    ) external returns (uint256);

    function setUint(
        bytes32 key,
        address field,
        uint256 value
    ) external;

    function getUint(bytes32 key, address field) external view returns (uint256);
}
