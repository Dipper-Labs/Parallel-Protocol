pragma solidity ^0.5.17;

interface IHolder {
    function lock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external;

    function unlock(
        bytes32 asset,
        address account,
        uint256 amount
    ) external;

    function getLocked(bytes32 asset, address account) external view returns (uint256);

    function getTotalLocked(bytes32 asset) external view returns (uint256);

    function getPeriodLocked(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256);

    function LOCK_ADDRESS() external view returns (address);
}
