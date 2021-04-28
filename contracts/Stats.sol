// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './base/Importable.sol';
import './interfaces/IStats.sol';
import './interfaces/ISynthx.sol';
import './interfaces/IEscrow.sol';
import './interfaces/IStaker.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/ISetting.sol';
import './interfaces/IIssuer.sol';
import './interfaces/ITrader.sol';
import './interfaces/IRewards.sol';
import './interfaces/ISynth.sol';
import './interfaces/IMarket.sol';
import './interfaces/IERC20.sol';

contract Stats is Importable, IStats {
    bytes32 private constant STAKE = 'Stake';
    bytes32 private constant SYNTH = 'Synth';

    using SafeMath for uint256;
    using PreciseMath for uint256;

    constructor(IResolver resolver) public Importable(resolver) {
        setContractName(CONTRACT_STATS);
        imports = [
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_SYNTHX,
            CONTRACT_ESCROW,
            CONTRACT_STAKER,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SETTING,
            CONTRACT_ISSUER,
            CONTRACT_TRADER,
            CONTRACT_MARKET
        ];
    }

    function Synthx() private view returns (ISynthx) {
        return ISynthx(requireAddress(CONTRACT_SYNTHX));
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
    }

    function Staker() private view returns (IStaker) {
        return IStaker(requireAddress(CONTRACT_STAKER));
    }

    function AssetPrice() private view returns (IAssetPrice) {
        return IAssetPrice(requireAddress(CONTRACT_ASSET_PRICE));
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Issuer() private view returns (IIssuer) {
        return IIssuer(requireAddress(CONTRACT_ISSUER));
    }

    function Trader() private view returns (ITrader) {
        return ITrader(requireAddress(CONTRACT_TRADER));
    }

    function Rewards(bytes32 reward) private view returns (IRewards) {
        return IRewards(requireAddress(reward));
    }

    function Market() private view returns (IMarket) {
        return IMarket(requireAddress(CONTRACT_MARKET));
    }

    function _getBalance(
        bytes32 assetName,
        address assetAddress,
        address account
    ) private view returns (uint256) {
        if (assetName == Synthx().nativeCoin()) return account.balance;

        IERC20 token = IERC20(assetAddress);
        return token.balanceOf(account).decimalsTo(token.decimals(), PreciseMath.DECIMALS());
    }

    function getBalance(address account) public view returns (Asset[] memory) {
        bytes32[] memory stakes = assets(STAKE);
        bytes32[] memory synths = assets(SYNTH);
        uint256[] memory prices = AssetPrice().getPrices(stakes);
        Asset[] memory items = new Asset[](stakes.length.add(synths.length));

        for (uint256 i = 0; i < stakes.length; i++) {
            bytes32 assetName = stakes[i];
            address assetAddress = requireAsset(STAKE, assetName);
            uint256 balance = _getBalance(assetName, assetAddress, account);
            items[i] = Asset(assetName, assetAddress, STAKE, balance, prices[i], 0);
        }

        prices = AssetPrice().getPrices(synths);
        for (uint256 i = 0; i < synths.length; i++) {
            bytes32 assetName = synths[i];
            address assetAddress = requireAsset(SYNTH, assetName);
            uint256 balance = _getBalance(assetName, assetAddress, account);
            items[i.add(stakes.length)] = Asset(assetName, assetAddress, SYNTH, balance, prices[i], 0);
        }

        return items;
    }

    function _getCategory(bytes32 assetType, address assetAddress) private view returns (bytes32) {
        if (assetType == SYNTH) return ISynth(assetAddress).category();
    }

    function getAsset(
        bytes32 assetType,
        bytes32 assetName,
        address account
    ) public view returns (Asset memory) {
        address assetAddress = requireAsset(assetType, assetName);
        (uint256 price, uint256 status) = AssetPrice().getPriceAndStatus(assetName);
        uint256 balance = _getBalance(assetName, assetAddress, account);
        return Asset(assetName, assetAddress, _getCategory(assetType, assetAddress), balance, price, status);
    }

    function getAssets(bytes32 assetType, address account) external view returns (Asset[] memory) {
        bytes32[] memory assets = assets(assetType);
        (uint256[] memory prices, uint256[] memory status) = AssetPrice().getPricesAndStatus(assets);
        Asset[] memory items = new Asset[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            bytes32 assetName = assets[i];
            address assetAddress = requireAsset(assetType, assetName);
            uint256 balance = _getBalance(assetName, assetAddress, account);
            items[i] = Asset(
                assetName,
                assetAddress,
                _getCategory(assetType, assetAddress),
                balance,
                prices[i],
                status[i]
            );
        }

        return items;
    }

    function _getVault(
        address account,
        bytes32 stakeName,
        uint256 stakePrice
    ) private view returns (Vault memory) {
        address stakeAddress = requireAsset(STAKE, stakeName);
        uint256 rewardCollateralRate = Setting().getCollateralRate(stakeName);
        uint256 liquidationCollateralRate = Setting().getLiquidationRate(stakeName);
        uint256 liquidationFeeRate = Setting().getLiquidationFeeRate(stakeName);
        uint256 staked = Staker().getStaked(stakeName, account);
        uint256 debt = Issuer().getDebt(stakeName, account);
        (uint256 transferable) = Staker().getTransferable(stakeName, account);
        uint256 balance = _getBalance(stakeName, stakeAddress, account);
        return
            Vault(
                stakeName,
                stakeAddress,
                staked.decimalMultiply(stakePrice).decimalDivide(debt),
                rewardCollateralRate,
                liquidationCollateralRate,
                liquidationFeeRate,
                staked,
                debt,
                transferable,
                balance,
                stakePrice
            );
    }

    function getVault(bytes32 stake, address account) external view returns (Vault memory) {
        uint256 price = AssetPrice().getPrice(stake);
        return _getVault(account, stake, price);
    }

    function getVaults(address account) public view returns (Vault[] memory) {
        bytes32[] memory stakes = assets(STAKE);
        uint256[] memory prices = AssetPrice().getPrices(stakes);

        Vault[] memory items = new Vault[](stakes.length);
        for (uint256 i = 0; i < stakes.length; i++) {
            items[i] = _getVault(account, stakes[i], prices[i]);
        }

        return items;
    }

    function getTotalCollateral(address account)
        external
        view
        returns (
            uint256 totalCollateralRatio,
            uint256 totalCollateralValue,
            uint256 totalDebt
        )
    {
        Vault[] memory vaults = getVaults(account);
        for (uint256 i = 0; i < vaults.length; i++) {
            Vault memory vault = vaults[i];
            totalCollateralValue = totalCollateralValue.add(vault.staked.decimalMultiply(vault.price));
            totalDebt = totalDebt.add(vault.debt);
        }
        totalCollateralRatio = totalCollateralValue.decimalDivide(totalDebt);
    }

    function getEscrowed(address account) external view returns (uint256 total) {
        return Escrow().getBalance(account);
    }

    function getAvailable(bytes32 stake, address account)
        external
        view
        returns (
            uint256 balance,
            uint256 escrowed,
            uint256 transferable
        )
    {
        bytes32 assetName = stake;
        address assetAddress = requireAsset(STAKE, assetName);
        balance = _getBalance(assetName, assetAddress, account);
        escrowed = (assetName == SDIP) ? Escrow().getBalance(account) : 0;
        (transferable) = Staker().getTransferable(assetName, account);
    }

    function getSynthValue(address account) external view returns (uint256) {
        bytes32[] memory synths = assets(SYNTH);
        uint256[] memory prices = AssetPrice().getPrices(synths);

        uint256 total = 0;
        for (uint256 i = 0; i < synths.length; i++) {
            bytes32 assetName = synths[i];
            address assetAddress = requireAsset(SYNTH, assetName);
            total = total.add(_getBalance(assetName, assetAddress, account).decimalMultiply(prices[i]));
        }

        return total;
    }

    function getTradingAmountAndFee(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    ) external view returns (uint256 tradingAmount, uint256 tradingFee) {
        (tradingAmount, tradingFee, , , , ) = Trader().getTradingAmountAndFee(fromSynth, fromAmount, toSynth);
    }

    function getTradingAmountAndFee2(
        bytes32 fromSynth,
        bytes32 toSynth,
        uint256 toAmount
    ) external view returns (uint256 tradingAmount, uint256 tradingFee) {
        (tradingAmount, tradingFee, , ) = Trader().getTradingAmountAndFee(fromSynth, toSynth, toAmount);
    }

    function getRequirdDUSDAmount(bytes32 assetType, address account, uint256 dTokenAmount) public view returns (uint256) {
        return Staker().getRequirdDUSDAmount(assetType, account, dTokenAmount);
    }

    function getWithdrawable(address account) external view returns (uint256) {
        return Escrow().getWithdrawable(account);
    }

    function getRewards(address account) external view returns (uint256) {
        return Rewards(CONTRACT_STAKER).getClaimable(SDIP, account);
    }

    function getAssetMarket(bytes32 asset)
        external
        view
        returns (
            uint256 open,
            uint256 last,
            uint256 low,
            uint256 hight,
            uint256 volume,
            uint256 turnover
        )
    {
        last = AssetPrice().getPrice(asset);
        (open, low, hight, volume, turnover) = Market().getAssetMarket(asset);
        if (open == 0) open = last;
        low = (low == 0) ? last : low.min(last);
        hight = hight.max(last);
    }

    function getLine(bytes32 asset, uint256 size) external view returns (uint256[] memory) {
        if (size == 0) return new uint256[](0);
        uint256[] memory line = Market().getLine(asset, size);
        line[size.sub(1)] = AssetPrice().getPrice(asset);
        return line;
    }

    function _getPair(
        bytes32 fromAsset,
        uint256 fromAssetPrice,
        uint256 fromAssetStatus,
        bytes32 toAsset,
        uint256 toAssetPrice,
        uint256 toAssetStatus,
        bytes32 category
    ) private view returns (Pair memory) {
        uint256 last = toAssetPrice.decimalDivide(fromAssetPrice);
        (uint256 open, uint256 low, uint256 hight, uint256 volume, uint256 turnover) =
            Market().getPairMarket(fromAsset, toAsset);
        if (open == 0) open = last;
        low = (low == 0) ? last : low.min(last);
        hight = hight.max(last);

        return
            Pair(
                fromAsset,
                fromAssetPrice,
                toAsset,
                toAssetPrice,
                category,
                open,
                last,
                low,
                hight,
                volume,
                turnover,
                (fromAssetStatus == 0 && toAssetStatus == 0) ? 0 : 1
            );
    }

    function getPair(bytes32 fromAsset, bytes32 toAsset) external view returns (Pair memory) {
        (uint256 fromAssetPrice, uint256 fromAssetStatus) = AssetPrice().getPriceAndStatus(fromAsset);
        (uint256 toAssetPrice, uint256 toAssetStatus) = AssetPrice().getPriceAndStatus(toAsset);
        address fromAssetAddress = requireAsset(SYNTH, fromAsset);
        bytes32 category = _getCategory(SYNTH, fromAssetAddress);
        return _getPair(fromAsset, fromAssetPrice, fromAssetStatus, toAsset, toAssetPrice, toAssetStatus, category);
    }

    function _addToPairs(Pair[] memory pairs, Pair memory pair) private pure returns (Pair[] memory) {
        Pair[] memory items = new Pair[](pairs.length.add(1));
        for (uint256 i = 0; i < pairs.length; i++) {
            items[i] = pairs[i];
        }
        items[pairs.length] = pair;
        return items;
    }

    function getPairs() external view returns (Pair[] memory) {
        bytes32[] memory assets = assets(SYNTH);
        Pair[] memory items = new Pair[](0);
        if (assets.length < 2) return items;

        (uint256[] memory prices, uint256[] memory status) = AssetPrice().getPricesAndStatus(assets);

        for (uint256 i = 0; i < assets.length; i++) {
            bytes32 fromAsset = assets[i];
            address fromAssetAddress = requireAsset(SYNTH, fromAsset);
            bytes32 category = _getCategory(SYNTH, fromAssetAddress);
            for (uint256 j = 0; j < assets.length; j++) {
                bytes32 toAsset = assets[j];
                if (fromAsset == toAsset) continue;
                items = _addToPairs(
                    items,
                    _getPair(fromAsset, prices[i], status[i], toAsset, prices[j], status[j], category)
                );
            }
        }

        return items;
    }

    function getTradingFee(address account, uint256 period) external view returns (uint256) {
        return Trader().getTradingFee(account, period);
    }

    function getDebtPercentage(
        bytes32 stake,
        address account,
        uint256 period
    ) external view returns (uint256) {
        return Issuer().getDebtPercentage(stake, account, period);
    }
}
