pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IEscrowStorage.sol';

contract EscrowStorage is ExternalStorage, IEscrowStorage {
    mapping(bytes32 => mapping(address => uint256)) private _storage;
    mapping(address => mapping(uint256 => uint256)) private _escrows;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setEscrow(
        address account,
        uint256 period,
        uint256 amount
    ) external onlyManager(managerName) returns (uint256) {
        _escrows[account][period] = _escrows[account][period].add(amount);
        return _escrows[account][period];
    }

    function getEscrow(address account, uint256 period) external view returns (uint256 amount) {
        amount = _escrows[account][period];
        return amount;
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

    function getUint(bytes32 key, address field) external view returns (uint256) {
        return _storage[key][field];
    }
}
