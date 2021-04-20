pragma solidity ^0.5.17;

import './RewardsStorage.sol';
import '../interfaces/storages/ITraderStorage.sol';

contract TraderStorage is RewardsStorage, ITraderStorage {
    mapping(address => mapping(uint256 => uint256)) private _storage;

    constructor(address _manager) public RewardsStorage(_manager) {}

    function incrementTradingFee(
        address account,
        uint256 period,
        uint256 amount
    ) external onlyManager(managerName) returns (uint256) {
        _storage[account][period] = _storage[account][period].add(amount);
        _storage[address(0)][period] = _storage[address(0)][period].add(amount);
        return _storage[account][period];
    }

    function getTradingFee(address account, uint256 period) external view returns (uint256) {
        return _storage[account][period];
    }
}
