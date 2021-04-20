pragma solidity ^0.5.17;

interface ISettingStorage {
    function incrementUint(
        bytes32 key,
        bytes32 field,
        uint256 value
    ) external returns (uint256);

    function decrementUint(
        bytes32 key,
        bytes32 field,
        uint256 value,
        string calldata errorMessage
    ) external returns (uint256);

    function setUint(
        bytes32 key,
        bytes32 field,
        uint256 value
    ) external;

    function getUint(bytes32 key, bytes32 field) external view returns (uint256);

    function incrementUint(bytes32 key, uint256 value) external returns (uint256);

    function decrementUint(
        bytes32 key,
        uint256 value,
        string calldata errorMessage
    ) external returns (uint256);

    function setUint(bytes32 key, uint256 value) external;

    function getUint(bytes32 key) external view returns (uint256);
}
