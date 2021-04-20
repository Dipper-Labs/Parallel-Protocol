pragma solidity ^0.5.17;

interface IProviderStorage {
    struct Locked {
        uint256 period;
        uint256 amount;
    }

    function incrementLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) external;

    function decrementLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount,
        string calldata errorMessage
    ) external;

    function getLocked(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);
}
