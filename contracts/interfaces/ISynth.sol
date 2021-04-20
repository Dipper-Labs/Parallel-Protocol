pragma solidity ^0.5.17;

interface ISynth {
    function category() external view returns (bytes32);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);
}
