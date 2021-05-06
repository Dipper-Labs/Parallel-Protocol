pragma solidity ^0.5.17;

interface IRewards {
    function getClaimed(
        address account,
        uint256 period
    ) external view returns (uint256);

    function claim(address account)
        external
        returns (
            uint256 period,
            uint256 amount
        );

    function getClaimable(address account) external view returns (uint256);
}
