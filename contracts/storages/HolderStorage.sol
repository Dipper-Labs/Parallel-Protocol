pragma solidity ^0.5.17;

import './RewardsStorage.sol';
import '../interfaces/storages/IHolderStorage.sol';

contract HolderStorage is RewardsStorage, IHolderStorage {
    mapping(address => mapping(bytes32 => Balance)) private _storage;

    constructor(address _manager) public RewardsStorage(_manager) {}

    function setBalance(
        address account,
        uint256 period,
        uint256 amount,
        uint256 total
    ) external onlyManager(managerName) {
        _setBalance(account, period, amount);
        _setBalance(address(0), period, total);
    }

    function _setBalance(
        address account,
        uint256 period,
        uint256 amount
    ) private {
        bytes32 PERIOD = bytes32(period);
        if (_storage[account][PERIOD].amount == 0 && _storage[account][DEFAULT].amount > 0)
            _storage[account][bytes32(period.sub(1))] = _storage[account][DEFAULT];

        _storage[account][PERIOD] = Balance(period, amount);
        _storage[account][DEFAULT] = _storage[account][PERIOD];
    }

    function getBalance(
        address account,
        uint256 period
    ) external view returns (uint256) {
        Balance memory balance = _storage[account][bytes32(period)];
        if (balance.amount == 0) balance = _storage[account][DEFAULT];
        if (balance.period > period) return 0;
        return balance.amount;
    }
}
