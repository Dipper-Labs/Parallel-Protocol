pragma solidity ^0.5.17;

import './RewardsStorage.sol';
import '../interfaces/storages/IStakerStorage.sol';

contract StakerStorage is RewardsStorage, IStakerStorage {
    mapping(bytes32 => mapping(address => uint256)) private _storage;

    constructor(address _manager) public RewardsStorage(_manager) {}

    function incrementStaked(
        bytes32 stake,
        address account,
        uint256 amount
    ) external onlyManager(managerName) returns (uint256) {
        _storage[stake][account] = _storage[stake][account].add(amount);
        _storage[stake][address(0)] = _storage[stake][address(0)].add(amount);
        return _storage[stake][account];
    }

    function decrementStaked(
        bytes32 stake,
        address account,
        uint256 amount,
        string calldata errorMessage
    ) external onlyManager(managerName) returns (uint256) {
        _storage[stake][account] = _storage[stake][account].sub(amount, errorMessage);
        _storage[stake][address(0)] = _storage[stake][address(0)].sub(amount, errorMessage);
        return _storage[stake][account];
    }

    function getStaked(bytes32 stake, address account) external view returns (uint256) {
        return _storage[stake][account];
    }
}
