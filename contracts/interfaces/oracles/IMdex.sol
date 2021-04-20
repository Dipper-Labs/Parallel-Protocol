pragma solidity ^0.5.17;

interface IMdex {
    function price(address token, uint256 baseDecimal) external view returns (uint256);
}
