pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import '../lib/Paging.sol';
import './ExternalStorage.sol';
import '../interfaces/storages/ILiquidatorStorage.sol';

contract LiquidatorStorage is ExternalStorage, ILiquidatorStorage {
    mapping(bytes32 => mapping(address => uint256[2])) private _storage;
    mapping(bytes32 => address[]) private _accounts;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function addWatch(
        bytes32 stake,
        address account,
        uint256 time
    ) external onlyManager(managerName) {
        if (_storage[stake][account][0] > 0) return;

        _storage[stake][account][1] = time;
        if (_storage[stake][account][0] == 0) _storage[stake][account][0] = _accounts[stake].push(account);
    }

    function removeWatch(bytes32 stake, address account) external onlyManager(managerName) {
        if (_storage[stake][account][0] == 0) return;
        uint256 length = _accounts[stake].length;
        if (length == 0) return;
        uint256 last = length.sub(1);
        _accounts[stake][_storage[stake][account][0].sub(1)] = _accounts[stake][last];
        delete _accounts[stake][last];
        delete _storage[stake][account];
        _accounts[stake].length = last;
    }

    function getDeadline(bytes32 stake, address account) external view returns (uint256) {
        return _storage[stake][account][1];
    }

    function getAccounts(
        bytes32 stake,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(_accounts[stake].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256 last = _accounts[stake].length;

        address[] memory items = new address[](page.pageRecords);
        for (uint256 i = 0; i < page.pageRecords; i++) {
            items[i] = _accounts[stake][last.sub(1).sub(start).sub(i)];
        }

        return (items, page);
    }
}
