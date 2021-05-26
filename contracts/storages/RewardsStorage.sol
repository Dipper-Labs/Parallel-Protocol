pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IRewardsStorage.sol';

contract RewardsStorage is ExternalStorage, IRewardsStorage {
     mapping(address => mapping(uint256 => uint256)) private _claimed;
     mapping(address => uint256) private _lastClaimedPeriod;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setClaimed(address account, uint256 period, uint256 amount) external onlyManager(managerName) {
        require(_claimed[account][period] == 0, 'RewardsStorage: already claimed');
        _claimed[account][period] = _claimed[account][period].add(amount);
        _claimed[address(0)][period] = _claimed[address(0)][period].add(amount);
    }

    function getClaimed(address account, uint256 period) external view returns (uint256) {
        return _claimed[account][period];
    }

    function setLastClaimedPeriod(address account, uint256 period) external onlyManager(managerName) {
        require(_lastClaimedPeriod[account] == 0, "RewardsStorage: already set last claimed");
        _lastClaimedPeriod[account] = period;
    }

    function getLastClaimedPeriod(address account) external view returns (uint256) {
        return _lastClaimedPeriod[account];
    }
}
