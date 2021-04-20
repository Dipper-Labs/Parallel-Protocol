pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IRewardsStorage.sol';

contract RewardsStorage is ExternalStorage, IRewardsStorage {
    mapping(bytes32 => uint256) private _percentages;
    mapping(bytes32 => mapping(address => mapping(uint256 => uint256))) private _claimed;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setRewardPercentage(bytes32 asset, uint256 percentage) external onlyManager(managerName) {
        _percentages[asset] = percentage;
    }

    function getRewardPercentage(bytes32 asset) external view returns (uint256) {
        return _percentages[asset];
    }

    function setClaimed(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) external onlyManager(managerName) {
        require(_claimed[asset][account][period] == 0, 'RewardsStorage: already claimed');
        _claimed[asset][account][period] = _claimed[asset][account][period].add(amount);
        _claimed[asset][address(0)][period] = _claimed[asset][address(0)][period].add(amount);
    }

    function getClaimed(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256) {
        return _claimed[asset][account][period];
    }
}
