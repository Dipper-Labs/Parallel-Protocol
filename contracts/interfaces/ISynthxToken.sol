pragma solidity ^0.5.17;

interface ISynthxToken {
    function mint() external returns (bool);

    function migrate(address from, address to) external returns (bool);
}
