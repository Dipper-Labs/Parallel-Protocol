// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './base/Importable.sol';
import './interfaces/IMarket.sol';

contract Market is Importable, IMarket {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    mapping(bytes32 => mapping(uint256 => Market)) private _storage;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_MARKET);
        imports = [CONTRACT_SYNBIT];
    }

    function addTrade(
        bytes32 fromSynth,
        uint256 fromAmount,
        uint256 fromSynthPrice,
        bytes32 toSynth,
        uint256 toAmount,
        uint256 toSynthPrice
    ) external containAddressOrOwner(imports) {
        uint256 turnover = fromAmount.decimalMultiply(fromSynthPrice);
        uint256 toPrice = toSynthPrice.decimalDivide(fromSynthPrice);
        _setAssetMarket(keccak256(abi.encodePacked(fromSynth, toSynth)), toPrice, toAmount, turnover);

        uint256 fromPrice = fromSynthPrice.decimalDivide(toSynthPrice);
        _setAssetMarket(keccak256(abi.encodePacked(toSynth, fromSynth)), fromPrice, fromAmount, turnover);

        _setAssetMarket(fromSynth, fromSynthPrice, fromAmount, turnover);
        _setAssetMarket(toSynth, toSynthPrice, toAmount, turnover);
    }

    function _setAssetMarket(
        bytes32 asset,
        uint256 price,
        uint256 volume,
        uint256 turnover
    ) private {
        uint256 hour = now / 3600;
        Market storage market = _storage[asset][hour];
        if (market.asset == bytes32(0)) {
            _storage[asset][hour] = Market(asset, price, price, price, price, volume, turnover, now);
        } else {
            market.last = price;
            market.low = price.min(market.low);
            market.hight = price.max(market.hight);
            market.volume = market.volume.add(volume);
            market.turnover = market.turnover.add(turnover);
            market.time = now;
        }
    }

    function getPairMarket(bytes32 fromSynth, bytes32 toSynth)
        external
        view
        returns (
            uint256 open,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        )
    {
        return getAssetMarket(keccak256(abi.encodePacked(fromSynth, toSynth)));
    }

    function getAssetMarket(bytes32 asset)
        public
        view
        returns (
            uint256 open,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        )
    {
        uint256 start = now / 3600;
        for (uint256 i = 0; i < 24; i++) {
            Market memory market = _storage[asset][start.sub(i)];
            if (market.asset == bytes32(0)) continue;
            open = market.open;
            low = (low == 0) ? market.low : market.low.min(low);
            hight = market.hight.max(hight);
            volume = volume.add(market.volume);
            turnover = turnover.add(market.turnover);
        }
    }

    function getLine(bytes32 asset, uint256 size) external view returns (uint256[] memory) {
        uint256 start = now / 3600;
        uint256 length = (size > 100) ? 100 : size;
        uint256[] memory line = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            Market memory market = _storage[asset][start.sub(i)];
            line[length.sub(1).sub(i)] = market.last;
        }
        return line;
    }

    function getMarkets(bytes32 asset, uint256 size) external view returns (Market[] memory) {
        uint256 start = now / 3600;
        uint256 length = (size > 100) ? 100 : size;
        Market[] memory items = new Market[](length);
        for (uint256 i = 0; i < length; i++) {
            items[i] = _storage[asset][start.sub(i)];
        }
        return items;
    }
}
