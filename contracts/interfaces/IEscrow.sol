pragma solidity ^0.5.17;

interface IEscrow {
    function deposit(
        uint256 period,
        address account,
        uint256 amount
    ) external;

    function withdraw(address account, uint256 amount) external;

    function getWithdrawable(address account) external view returns (uint256);

    function getBalance(address account) external view returns (uint256);
}
