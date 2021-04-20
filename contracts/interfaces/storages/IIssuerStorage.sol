pragma solidity ^0.5.17;

interface IIssuerStorage {
    struct Debt {
        uint256 period;
        uint256 account;
        uint256 total;
        uint256 time;
    }

    function setDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 accountDebt,
        uint256 totalDebt,
        uint256 time
    ) external;

    function getDebt(
        bytes32 stake,
        address account,
        uint256 period
    )
        external
        view
        returns (
            uint256 accountDebt,
            uint256 totalDebt,
            uint256 time
        );

    function getLastDebt(uint256 period) external view returns (uint256);
}
