pragma solidity ^0.5.17;

interface IStakerStorage {
    function incrementStaked(
        bytes32 stake,
        address account,
        uint256 amount
    ) external returns (uint256);

    function decrementStaked(
        bytes32 stake,
        address account,
        uint256 amount,
        string calldata errorMessage
    ) external returns (uint256);

    function getStaked(bytes32 stake, address account) external view returns (uint256);
}
