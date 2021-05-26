pragma solidity ^0.5.17;

interface IHolder {
    function updateBalance(address account) external;

    function getBalance(address account) external view returns (uint256);

    function getTotalSupply() external view returns (uint256);

    function getPeriodBalance(address account, uint256 period) external view returns (uint256);

    function getClaimable(address account) external view returns (uint256);

    function claim(address account) external returns (uint256 period, uint256 amount);
}
