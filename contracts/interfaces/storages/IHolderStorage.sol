pragma solidity ^0.5.17;

interface IHolderStorage {
    struct Balance {
        uint256 period;
        uint256 amount;
    }

    function setBalance(
        address account,
        uint256 period,
        uint256 amount,
        uint256 total
    ) external;

    function getBalance(
        address account,
        uint256 period
    ) external view returns (uint256);
}
