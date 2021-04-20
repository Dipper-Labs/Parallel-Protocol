// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/Arrays.sol';
import './storages/AddressStorage.sol';
import './interfaces/IResolver.sol';
import './interfaces/ISynbitToken.sol';

contract Resolver is AddressStorage, IResolver {
    mapping(bytes32 => bytes32[]) _assets;

    constructor() public {
        setContractName(CONTRACT_RESOLVER);
    }

    function addAsset(
        bytes32 assetType,
        bytes32 assetName,
        address assetAddress
    ) external onlyOwner {
        Arrays.push(_assets[assetType], assetName);
        emit AssetChanged(assetType, assetName, getAddressValue(assetType, assetName), assetAddress);
        setAddressValue(assetType, assetName, assetAddress);
    }

    function removeAsset(bytes32 assetType, bytes32 assetName) external onlyOwner {
        Arrays.remove(_assets[assetType], assetName);
        emit AssetChanged(assetType, assetName, getAddressValue(assetType, assetName), address(0));
        removeAddressValue(assetType, assetName);
    }

    function getAsset(bytes32 assetType, bytes32 assetName) external view returns (bool, address) {
        (bool exist, ) = Arrays.index(_assets[assetType], assetName);
        return (exist, getAddressValue(assetType, assetName));
    }

    function getAssets(bytes32 assetType) external view returns (bytes32[] memory) {
        return _assets[assetType];
    }

    function importAddress(bytes32[] calldata name, address[] calldata value) external onlyOwner {
        require(name.length == value.length, 'Resolver: name and value length mismatch');
        for (uint256 i = 0; i < name.length; i++) {
            setAddress(name[i], value[i]);
        }
    }

    function setAddress(bytes32 name, address value) public onlyOwner {
        address previousValue = getAddressValue(name);
        emit AddressChanged(name, previousValue, value);
        _migrateSynbitToken(name, previousValue, value);
        setAddressValue(name, value);
    }

    function getAddress(bytes32 name) external view returns (address) {
        return getAddressValue(name);
    }

    function _migrateSynbitToken(
        bytes32 name,
        address previousAddress,
        address newAddress
    ) private {
        bytes32[3] memory contracts = [CONTRACT_ESCROW, CONTRACT_HOLDER, CONTRACT_TRADER];
        if (previousAddress == address(0)) return;
        address synbitToken = getAddressValue(CONTRACT_SYNBIT_TOKEN);
        if (synbitToken == address(0)) return;
        for (uint256 i = 0; i < contracts.length; i++) {
            if (name != contracts[i]) continue;
            ISynbitToken(synbitToken).migrate(previousAddress, newAddress);
            emit SynbitTokenMigrated(name, previousAddress, newAddress);
        }
    }
}
