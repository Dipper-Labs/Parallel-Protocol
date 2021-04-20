pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/ISettingStorage.sol';

contract SettingStorage is ExternalStorage, ISettingStorage {
    mapping(bytes32 => mapping(bytes32 => uint256)) private _storage;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function incrementUint(
        bytes32 key,
        bytes32 field,
        uint256 value
    ) external onlyManager(managerName) returns (uint256) {
        _storage[key][field] = _storage[key][field].add(value);
        return _storage[key][field];
    }

    function decrementUint(
        bytes32 key,
        bytes32 field,
        uint256 value,
        string calldata errorMessage
    ) external onlyManager(managerName) returns (uint256) {
        _storage[key][field] = _storage[key][field].sub(value, errorMessage);
        return _storage[key][field];
    }

    function setUint(
        bytes32 key,
        bytes32 field,
        uint256 value
    ) external onlyManager(managerName) {
        _storage[key][field] = value;
    }

    function getUint(bytes32 key, bytes32 field) external view returns (uint256) {
        return _storage[key][field];
    }

    function incrementUint(bytes32 key, uint256 value) external onlyManager(managerName) returns (uint256) {
        _storage[DEFAULT][key] = _storage[DEFAULT][key].add(value);
        return _storage[DEFAULT][key];
    }

    function decrementUint(
        bytes32 key,
        uint256 value,
        string calldata errorMessage
    ) external onlyManager(managerName) returns (uint256) {
        _storage[DEFAULT][key] = _storage[DEFAULT][key].sub(value, errorMessage);
        return _storage[DEFAULT][key];
    }

    function setUint(bytes32 key, uint256 value) external onlyManager(managerName) {
        _storage[DEFAULT][key] = value;
    }

    function getUint(bytes32 key) external view returns (uint256) {
        return _storage[DEFAULT][key];
    }
}
