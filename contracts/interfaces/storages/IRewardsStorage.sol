pragma solidity ^0.5.17;

interface IRewardsStorage {
    struct Claim {
        uint256 amount;
        uint256 time;
    }

    function setRewardPercentage(bytes32 asset, uint256 percentage) external;

    function getRewardPercentage(bytes32 asset) external view returns (uint256);

    function setClaimed(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) external;

    function getClaimed(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);
}
