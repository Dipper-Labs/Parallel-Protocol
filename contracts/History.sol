// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/Paging.sol';
import './base/Importable.sol';
import './interfaces/IHistory.sol';

contract History is Importable, IHistory {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    Action[] private _actions;
    mapping(bytes32 => uint256[]) private _assetTrades;
    mapping(bytes32 => mapping(address => uint256[])) private _accountActions;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_HISTORY);
        imports = [CONTRACT_SYNBIT, CONTRACT_SUPPLY_SCHEDULE, CONTRACT_CROWDSALE];
    }

    function addAction(
        bytes32 topic,
        address account,
        bytes32 actionType,
        bytes32 fromAsset,
        uint256 fromAmount,
        bytes32 toAsset,
        uint256 toAmount
    ) external containAddressOrOwner(imports) {
        uint256 index = _actions.push(Action(actionType, fromAsset, fromAmount, 0, toAsset, toAmount, 0, now));
        _accountActions[topic][account].push(index);
    }

    function addTrade(
        address account,
        bytes32 fromSynth,
        uint256 fromAmount,
        uint256 fromSynthPrice,
        bytes32 toSynth,
        uint256 toAmount,
        uint256 toSynthPirce
    ) external containAddressOrOwner(imports) {
        bytes32 asset = keccak256(abi.encodePacked(fromSynth & toSynth));

        uint256 index =
            _actions.push(Action('Trade', fromSynth, fromAmount, fromSynthPrice, toSynth, toAmount, toSynthPirce, now));
        _assetTrades[asset].push(index);
        _accountActions['Trade'][account].push(index);
    }

    function getHistory(
        bytes32 topic,
        address account,
        uint256 pageSize,
        uint256 pageNumber
    ) public view returns (Action[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(_accountActions[topic][account].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256 last = _accountActions[topic][account].length;

        Action[] memory items = new Action[](page.pageRecords);
        for (uint256 i = 0; i < page.pageRecords; i++) {
            uint256 index = _accountActions[topic][account][last.sub(1).sub(start).sub(i)];
            items[i] = _actions[index.sub(1)];
        }

        return (items, page);
    }

    function getAssetHistory(
        bytes32 asset,
        uint256 pageSize,
        uint256 pageNumber
    ) public view returns (Action[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(_assetTrades[asset].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256 last = _assetTrades[asset].length;

        Action[] memory items = new Action[](page.pageRecords);
        for (uint256 i = 0; i < page.pageRecords; i++) {
            uint256 index = _assetTrades[asset][last.sub(1).sub(start).sub(i)];
            items[i] = _actions[index.sub(1)];
        }

        return (items, page);
    }

    function getPairHistory(
        bytes32 fromSynth,
        bytes32 toSynth,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (Action[] memory, Paging.Page memory) {
        bytes32 asset = keccak256(abi.encodePacked(fromSynth & toSynth));
        return getAssetHistory(asset, pageSize, pageNumber);
    }
}
