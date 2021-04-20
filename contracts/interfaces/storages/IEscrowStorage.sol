pragma solidity ^0.5.17;

interface IEscrowStorage {
    struct Escrow {
        uint256 amount;
        uint256 time;
    }

    function setEscrow(
        address account,
        uint256 period,
        uint256 amount,
        uint256 time
    ) external returns (uint256);

    function getEscrow(address account, uint256 period) external view returns (uint256 amount, uint256 time);

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

    function getUint(bytes32 key, address field) external view returns (uint256);
}
