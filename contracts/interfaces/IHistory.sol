pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import '../lib/Paging.sol';

interface IHistory {
    struct Action {
        bytes32 actionType;
        bytes32 fromAsset;
        uint256 fromAmount;
        uint256 fromPrice;
        bytes32 toAsset;
        uint256 toAmount;
        uint256 toPrice;
        uint256 time;
    }

    function addAction(
        bytes32 topic,
        address account,
        bytes32 actionType,
        bytes32 fromAsset,
        uint256 fromAmount,
        bytes32 toAsset,
        uint256 toAmount
    ) external;

    function addTrade(
        address account,
        bytes32 fromSynth,
        uint256 fromAmount,
        uint256 fromSynthPrice,
        bytes32 toSynth,
        uint256 toAmount,
        uint256 toSynthPirce
    ) external;

    function getHistory(
        bytes32 topic,
        address account,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (Action[] memory, Paging.Page memory);

    function getAssetHistory(
        bytes32 asset,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (Action[] memory, Paging.Page memory);

    function getPairHistory(
        bytes32 fromSynth,
        bytes32 toSynth,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (Action[] memory, Paging.Page memory);
}
