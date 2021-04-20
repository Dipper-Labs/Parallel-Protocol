pragma solidity ^0.5.17;

interface ISupplySchedule {
    function distributeSupply() external returns (address[] memory recipients, uint256[] memory amounts);

    function mintableSupply(bytes32 recipient, uint256 period) external view returns (uint256);

    function periodSupply(bytes32 recipient, uint256 period) external view returns (uint256);

    function periodSupply(uint256 period) external view returns (uint256);

    function currentPeriod() external view returns (uint256);

    function lastMintPeriod() external view returns (uint256);

    function nextMintTime() external view returns (uint256);

    function lastMintTime() external view returns (uint256);

    function startMintTime() external view returns (uint256);

    event SupplyPercentageChanged(bytes32 indexed recipient, uint256 indexed previousValue, uint256 indexed newValue);
}
