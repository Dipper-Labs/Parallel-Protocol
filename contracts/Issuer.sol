// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/Address.sol';
import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './base/Importable.sol';
import './base/ExternalStorable.sol';
import './interfaces/IIssuer.sol';
import './interfaces/storages/IIssuerStorage.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/ISetting.sol';
import './interfaces/ISynth.sol';
import './interfaces/IERC20.sol';

contract Issuer is Importable, ExternalStorable, IIssuer {
    bytes32 private constant SYNTH = 'Synth';
    bytes32 private constant LAST = 'Last';

    using Address for address;
    using SafeMath for uint256;
    using PreciseMath for uint256;

    bytes32[] private ISSUEABLE_CONTRACTS = [CONTRACT_TRADER, CONTRACT_STAKER];

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_ISSUER);
        imports = [
            CONTRACT_SYNTHX,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SETTING,
            CONTRACT_TRADER,
            CONTRACT_STAKER
        ];
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function AssetPrice() private view returns (IAssetPrice) {
        return IAssetPrice(requireAddress(CONTRACT_ASSET_PRICE));
    }

    function Synth(bytes32 synth) private view returns (ISynth) {
        return ISynth(requireAsset('Synth', synth));
    }

    function Storage() internal view returns (IIssuerStorage) {
        return IIssuerStorage(getStorage());
    }

    function issueDebt(
        bytes32 stake,
        address account,
        uint256 amount,
        uint256 dTokenMintedAmount
    ) external onlyAddress(CONTRACT_SYNTHX) {
        Item memory item;

        uint256 currentPeriod = getCurrentPeriod();
        uint256 totalDebt = getTotalDebt();
        (uint256 lastDebt,) = Storage().getLastDebt(currentPeriod);

        (item.accountDebt, item.dtokens, ) = _getDebt(stake, account, currentPeriod, lastDebt, totalDebt);
        (item.stakeDebt, , ) = _getDebt(stake, address(0), currentPeriod, lastDebt, totalDebt);

        uint256 newTotalDebt = totalDebt.add(amount);
        uint256 newLastDebt = PreciseMath.PRECISE_ONE();
        item.dtokens = item.dtokens.add(dTokenMintedAmount);

        if (lastDebt > 0) {
            uint256 delta = amount.preciseDivide(newTotalDebt);
            newLastDebt = lastDebt.preciseMultiply(PreciseMath.PRECISE_ONE().sub(delta));
        }

        _setDebt(
            stake,
            account,
            currentPeriod,
            item.accountDebt.add(amount),
            item.stakeDebt.add(amount),
            newTotalDebt,
            newLastDebt,
            item.dtokens,
            now
        );

        Synth(USD).mint(account, amount);
    }

    struct Item {
        uint256 accountDebt;
        uint256 dtokens;
        uint256 stakeDebt;
        uint256 lastTime;
    }

    function burnDebt(
        bytes32 stake,
        address account,
        uint256 amount,
        address payer
    ) external onlyAddress(CONTRACT_SYNTHX) returns (uint256) {
        Item memory item;

        uint256 currentPeriod = getCurrentPeriod();
        uint256 totalDebt = getTotalDebt();
        (uint256 lastDebt, ) = Storage().getLastDebt(currentPeriod);

        (item.accountDebt, item.lastTime, item.dtokens) = _getDebt(stake, account, currentPeriod, lastDebt, totalDebt);
        (item.stakeDebt, , ) = _getDebt(stake, address(0), currentPeriod, lastDebt, totalDebt);
        require(amount <= item.dtokens, 'Issuer: burnable dtokens too large');

        uint256 burnableAmount = item.accountDebt.min(amount);
        require(burnableAmount > 0, 'Issuer: burnable is zero');

        uint256 newTotalDebt = totalDebt.sub(burnableAmount);
        uint256 newLastDebt = 0;
        item.dtokens = item.dtokens.sub(amount);

        if (newTotalDebt > 0) {
            uint256 delta = burnableAmount.preciseDivide(newTotalDebt);
            newLastDebt = lastDebt.preciseMultiply(PreciseMath.PRECISE_ONE().add(delta));
        }

        _setDebt(
            stake,
            account,
            currentPeriod,
            item.accountDebt.sub(burnableAmount),
            item.stakeDebt.sub(burnableAmount),
            newTotalDebt,
            newLastDebt,
            item.dtokens,
            item.lastTime
        );

        Synth(USD).burn(payer, burnableAmount);
        return burnableAmount;
    }

    function issueSynth(
        bytes32 synth,
        address account,
        uint256 amount
    ) external containAddress(ISSUEABLE_CONTRACTS) {
        Synth(synth).mint(account, amount);
    }

    function burnSynth(
        bytes32 synth,
        address account,
        uint256 amount
    ) external containAddress(ISSUEABLE_CONTRACTS) {
        Synth(synth).burn(account, amount);
    }

    function getDebt(bytes32 stake, address account) external view returns (uint256, uint256) {
        uint256 currentPeriod = getCurrentPeriod();
        (uint256 lastDebt, ) = Storage().getLastDebt(currentPeriod);
        (uint256 debt, uint256 dtokens, ) =
            _getDebt(stake, account, currentPeriod, lastDebt, getTotalDebt());
        return (debt, dtokens);
    }

    function getTotalDebt() public view returns (uint256) {
        bytes32[] memory synths = assets(SYNTH);
        uint256[] memory prices = AssetPrice().getPrices(synths);
        uint256 total = 0;
        for (uint256 i = 0; i < synths.length; i++) {
            address synth = requireAsset(SYNTH, synths[i]);
            total = total.add(IERC20(synth).totalSupply().decimalMultiply(prices[i]));
        }
        return total;
    }

    function getDebtPercentage(
        bytes32 stake,
        address account,
        uint256 period
    ) external view returns (uint256) {
        (uint256 lastDebt, ) = Storage().getLastDebt(period);
        (uint256 debtPercentage, , ) = _getDebtPercentage(stake, account, period, lastDebt);
        return debtPercentage;
    }

    function _getDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 lastDebt,
        uint256 totalDebt
    ) private view returns (uint256, uint256, uint256) {
        (uint256 debtPercentage, uint256 dtokens, uint256 time) = _getDebtPercentage(stake, account, period, lastDebt);
        return (totalDebt.toPrecise().preciseMultiply(debtPercentage).toDecimal(), dtokens, time);
    }

    function _getDebtPercentage(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 lastDebt
    ) private view returns (uint256, uint256, uint256) {
        (uint256 accountDebt, uint256 totalDebt, uint256 dtokens, uint256 time) = Storage().getDebt(stake, account, period);
        if (time == 0) return (0, 0, 0);
        return (lastDebt.preciseDivide(totalDebt).preciseMultiply(accountDebt), dtokens, time);
    }

    function _setDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 accountDebt,
        uint256 stakeDebt,
        uint256 totalDebt,
        uint256 lastDebt,
        uint256 dtokens,
        uint256 time
    ) private {
        Storage().setDebt(stake, account, period, accountDebt.preciseDivide(totalDebt), lastDebt, dtokens, time);
        Storage().setDebt(stake, address(0), period, stakeDebt.preciseDivide(totalDebt), lastDebt, dtokens, time);
    }
}
