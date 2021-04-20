pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import '../lib/Paging.sol';

interface IMarket {
    struct Market {
        bytes32 asset;
        uint256 open;
        uint256 last;
        uint256 low;
        uint256 hight;
        uint256 volume;
        uint256 turnover;
        uint256 time;
    }

    function addTrade(
        bytes32 fromSynth,
        uint256 fromAmount,
        uint256 fromSynthPrice,
        bytes32 toSynth,
        uint256 toAmount,
        uint256 toSynthPirce
    ) external;

    function getPairMarket(bytes32 fromSynth, bytes32 toSynth)
        external
        view
        returns (
            uint256 open,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        );

    function getAssetMarket(bytes32 asset)
        external
        view
        returns (
            uint256 open,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        );

    function getLine(bytes32 asset, uint256 size) external view returns (uint256[] memory);

    function getMarkets(bytes32 asset, uint256 size) external view returns (Market[] memory);
}
