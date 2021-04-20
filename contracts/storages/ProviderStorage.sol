pragma solidity ^0.5.17;

import './RewardsStorage.sol';
import '../interfaces/storages/IProviderStorage.sol';

contract ProviderStorage is RewardsStorage, IProviderStorage {
    mapping(bytes32 => mapping(address => mapping(bytes32 => Locked))) private _storage;

    constructor(address _manager) public RewardsStorage(_manager) {}

    function incrementLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) external onlyManager(managerName) {
        _setLocked(asset, account, period, _storage[asset][account][DEFAULT].amount.add(amount));
        _setLocked(asset, address(0), period, _storage[asset][address(0)][DEFAULT].amount.add(amount));
    }

    function decrementLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount,
        string calldata errorMessage
    ) external onlyManager(managerName) {
        _setLocked(asset, account, period, _storage[asset][account][DEFAULT].amount.sub(amount, errorMessage));
        _setLocked(asset, address(0), period, _storage[asset][address(0)][DEFAULT].amount.sub(amount, errorMessage));
    }

    function _setLocked(
        bytes32 asset,
        address account,
        uint256 period,
        uint256 amount
    ) private {
        bytes32 PERIOD = bytes32(period);
        if (_storage[asset][account][PERIOD].amount == 0 && _storage[asset][account][DEFAULT].amount > 0)
            _storage[asset][account][bytes32(period.sub(1))] = _storage[asset][account][DEFAULT];

        _storage[asset][account][PERIOD] = Locked(period, amount);
        _storage[asset][account][DEFAULT] = _storage[asset][account][PERIOD];
    }

    function getLocked(
        bytes32 asset,
        address account,
        uint256 period
    ) external view returns (uint256) {
        Locked memory locked = _storage[asset][account][bytes32(period)];
        if (locked.amount == 0) locked = _storage[asset][account][DEFAULT];
        if (locked.period > period) return 0;
        return locked.amount;
    }
}
