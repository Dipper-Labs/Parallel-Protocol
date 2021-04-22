pragma solidity ^0.5.17;

interface ISynthxDToken {
    function mint(address account, uint256 amount) external returns (bool);

    function migrate(address from, address to) external returns (bool);
}
