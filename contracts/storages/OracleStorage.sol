pragma solidity ^0.5.17;

import '../lib/SafeMath.sol';
import './ExternalStorage.sol';
import '../interfaces/storages/IOracleStorage.sol';

contract OracleStorage is ExternalStorage, IOracleStorage {
    using SafeMath for uint256;

    mapping(bytes32 => uint256) private _round;
    mapping(bytes32 => mapping(uint256 => Price)) private _storage;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function setRound(bytes32 asset, uint256 round) external onlyManager(managerName) {
        _round[asset] = round;
    }

    function getRound(bytes32 asset) external view returns (uint256) {
        return _round[asset];
    }

    function setPrice(bytes32 asset, uint256 price) external onlyManager(managerName) {
        _round[asset] = _round[asset].add(1);
        _storage[asset][_round[asset]] = Price(price, now);
    }

    function getPrice(bytes32 asset, uint256 round) external view returns (uint256 price, uint256 time) {
        Price memory p = _storage[asset][round];
        return (p.price, p.time);
    }
}
