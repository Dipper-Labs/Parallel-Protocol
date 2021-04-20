pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/ITokenStorage.sol';

contract TokenStorage is ExternalStorage, ITokenStorage {
    mapping(bytes32 => mapping(address => uint256)) private _storage;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setAllowance(
        address key,
        address field,
        uint256 value
    ) external onlyManager(managerName) {
        _allowances[key][field] = value;
    }

    function getAllowance(address key, address field) external view returns (uint256) {
        return _allowances[key][field];
    }

    function incrementUint(
        bytes32 key,
        address field,
        uint256 value
    ) external onlyManager(managerName) returns (uint256) {
        _storage[key][field] = _storage[key][field].add(value);
        return _storage[key][field];
    }

    function decrementUint(
        bytes32 key,
        address field,
        uint256 value,
        string calldata errorMessage
    ) external onlyManager(managerName) returns (uint256) {
        _storage[key][field] = _storage[key][field].sub(value, errorMessage);
        return _storage[key][field];
    }

    function setUint(
        bytes32 key,
        address field,
        uint256 value
    ) external onlyManager(managerName) {
        _storage[key][field] = value;
    }

    function getUint(bytes32 key, address field) external view returns (uint256) {
        return _storage[key][field];
    }
}
