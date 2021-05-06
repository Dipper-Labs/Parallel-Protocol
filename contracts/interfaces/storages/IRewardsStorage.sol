pragma solidity ^0.5.17;

interface IRewardsStorage {
    struct Claim {
        uint256 amount;
        uint256 time;
    }
    function setClaimed(
        address account,
        uint256 period,
        uint256 amount
    ) external;

    function getClaimed(
        address account,
        uint256 period
    ) external view returns (uint256);
}
