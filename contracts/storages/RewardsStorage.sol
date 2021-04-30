pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IRewardsStorage.sol';

contract RewardsStorage is ExternalStorage, IRewardsStorage {
     mapping(address => mapping(uint256 => uint256)) private _claimed;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setClaimed(
        address account,
        uint256 period,
        uint256 amount
    ) external onlyManager(managerName) {
        require(_claimed[account][period] == 0, 'RewardsStorage: already claimed');
        _claimed[account][period] = _claimed[account][period].add(amount);
        _claimed[address(0)][period] = _claimed[address(0)][period].add(amount);
    }

    function getClaimed(
        address account,
        uint256 period
    ) external view returns (uint256) {
        return _claimed[account][period];
    }
}
