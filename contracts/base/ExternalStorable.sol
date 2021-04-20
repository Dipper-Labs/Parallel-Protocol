pragma solidity ^0.5.17;

import './Ownable.sol';

contract ExternalStorable is Ownable {
    address private _storage;

    event StorageChanged(address indexed previousValue, address indexed newValue);

    modifier onlyStorageSetup() {
        require(_storage != address(0), contractName.concat(': Storage not set'));
        _;
    }

    function setStorage(address value) public onlyOwner {
        emit StorageChanged(_storage, value);
        _storage = value;
    }

    function getStorage() public view onlyStorageSetup returns (address) {
        return _storage;
    }
}
