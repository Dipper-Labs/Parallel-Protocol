pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IIssuerStorage.sol';

contract IssuerStorage is ExternalStorage, IIssuerStorage {
    mapping(bytes32 => mapping(address => mapping(bytes32 => Debt))) private _storage;

    mapping(bytes32 => Debt) private _last;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 accountDebt,
        uint256 totalDebt,
        uint256 time
    ) external onlyManager(managerName) {
        bytes32 PERIOD = bytes32(period);

        if (_storage[stake][account][PERIOD].time == 0 && _storage[stake][account][DEFAULT].time > 0)
            _storage[stake][account][bytes32(period.sub(1))] = _storage[stake][account][DEFAULT];

        if (_last[PERIOD].time == 0 && _last[DEFAULT].time > 0) _last[bytes32(period.sub(1))] = _last[DEFAULT];

        _storage[stake][account][PERIOD] = Debt(period, accountDebt, totalDebt, time);
        _storage[stake][account][DEFAULT] = _storage[stake][account][PERIOD];

        _last[PERIOD] = _storage[stake][account][PERIOD];
        _last[DEFAULT] = _storage[stake][account][PERIOD];
    }

    function getDebt(
        bytes32 stake,
        address account,
        uint256 period
    )
        external
        view
        returns (
            uint256 accountDebt,
            uint256 totalDebt,
            uint256 time
        )
    {
        Debt memory debt = _storage[stake][account][bytes32(period)];
        if (debt.time == 0) debt = _storage[stake][account][DEFAULT];
        if (debt.period > period) return (0, 0, 0);
        return (debt.account, debt.total, debt.time);
    }

    function getLastDebt(uint256 period) external view returns (uint256) {
        Debt memory debt = _last[bytes32(period)];
        if (debt.time == 0) debt = _last[DEFAULT];
        if (debt.period > period) return 0;
        return debt.total;
    }
}
