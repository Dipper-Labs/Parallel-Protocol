pragma solidity ^0.5.17;

import '../base/Storage.sol';

contract AddressStorage is Storage {
    mapping(bytes32 => mapping(bytes32 => address)) private _storage;

    function setAddressValue(bytes32 key, address value) internal {
        _storage[DEFAULT][key] = value;
    }

    function removeAddressValue(bytes32 key) internal {
        delete _storage[DEFAULT][key];
    }

    function getAddressValue(bytes32 key) internal view returns (address) {
        return _storage[DEFAULT][key];
    }

    function setAddressValue(
        bytes32 key,
        bytes32 field,
        address value
    ) internal {
        _storage[key][field] = value;
    }

    function removeAddressValue(bytes32 key, bytes32 field) internal {
        delete _storage[key][field];
    }

    function getAddressValue(bytes32 key, bytes32 field) internal view returns (address) {
        return _storage[key][field];
    }
}
