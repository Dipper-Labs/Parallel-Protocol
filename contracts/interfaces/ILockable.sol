pragma solidity ^0.5.17;

interface ILockable {
    function lock(address account, uint256 amount) external returns (bool);

    function unlock(address account, uint256 amount) external returns (bool);

    function getLocked(address account) external view returns (uint256);

    function getTotalLocked() external view returns (uint256);

    event HolderChanged(address indexed previousValue, address indexed newValue);
}
