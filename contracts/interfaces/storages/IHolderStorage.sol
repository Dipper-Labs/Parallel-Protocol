pragma solidity ^0.5.17;

interface IHolderStorage {
    struct Locked {
        uint256 period;
        uint256 amount;
    }

    function setLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount,
        uint256 total
    ) external;

    function getLocked(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);
}
