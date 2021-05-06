pragma solidity ^0.5.17;

interface IHolder {
    function addShares(
        bytes32 asset,
        address account,
        uint256 amount
    ) external;

    function removeShares(
        bytes32 asset,
        address account,
        uint256 amount
    ) external;

    function getShares(bytes32 asset, address account) external view returns (uint256);

    function getTotalShares(bytes32 asset) external view returns (uint256);

    function getPeriodShares(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);

    function getClaimable(address account) external view returns (uint256);

    function claim(address account)
    external
    returns (
        uint256 period,
        uint256 amount
    );
}
