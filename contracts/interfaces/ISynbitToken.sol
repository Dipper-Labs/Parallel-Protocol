pragma solidity ^0.5.17;

interface ISynbitToken {
    function mint() external returns (bool);

    function migrate(address from, address to) external returns (bool);

    event CrowdsaleSupplyDistributed(address indexed account, uint256 amount);
}
