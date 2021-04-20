pragma solidity ^0.5.17;

interface IRewards {
    function getRewardPercentage(bytes32 asset) external view returns (uint256);

    function getClaimed(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);

    function claim(bytes32 asset, address account)
        external
        returns (
            uint256 period,
            uint256 amount,
            uint256 vestTime
        );

    function getClaimable(bytes32 asset, address account) external view returns (uint256);

    event RewardPercentageChanged(bytes32 indexed asset, uint256 previousValue, uint256 newValue);
}
