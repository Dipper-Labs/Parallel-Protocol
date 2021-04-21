pragma solidity ^0.5.17;

interface ISynthxDToken {
    function mint() external returns (bool);

    function migrate(address from, address to) external returns (bool);
}
