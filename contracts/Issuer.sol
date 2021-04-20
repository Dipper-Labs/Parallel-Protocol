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
import './interfaces/IEscrow.sol';
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
            CONTRACT_SYNBIT,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SETTING,
            CONTRACT_ESCROW,
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

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
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
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNBIT) {
        uint256 currentPeriod = getCurrentPeriod();
        uint256 totalDebt = getTotalDebt();
        uint256 lastDebt = Storage().getLastDebt(currentPeriod);

        (uint256 accountDebt, ) = _getDebt(stake, account, currentPeriod, lastDebt, totalDebt);
        (uint256 stakeDebt, ) = _getDebt(stake, address(0), currentPeriod, lastDebt, totalDebt);

        uint256 newTotalDebt = totalDebt.add(amount);
        uint256 newLastDebt = PreciseMath.PRECISE_ONE();

        if (lastDebt > 0) {
            uint256 delta = amount.preciseDivide(newTotalDebt);
            newLastDebt = lastDebt.preciseMultiply(PreciseMath.PRECISE_ONE().sub(delta));
        }

        _setDebt(
            stake,
            account,
            currentPeriod,
            accountDebt.add(amount),
            stakeDebt.add(amount),
            newTotalDebt,
            newLastDebt,
            now
        );

        Synth(USD).mint(account, amount);
    }

    function burnDebt(
        bytes32 stake,
        address account,
        uint256 amount,
        address payer
    ) external onlyAddress(CONTRACT_SYNBIT) returns (uint256) {
        uint256 currentPeriod = getCurrentPeriod();
        uint256 totalDebt = getTotalDebt();
        uint256 lastDebt = Storage().getLastDebt(currentPeriod);

        (uint256 accountDebt, uint256 lastTime) = _getDebt(stake, account, currentPeriod, lastDebt, totalDebt);
        require(_canBurn(lastTime), 'Issuer: Minimum stake time not reached');
        (uint256 stakeDebt, ) = _getDebt(stake, address(0), currentPeriod, lastDebt, totalDebt);

        uint256 burnableAmount = accountDebt.min(amount);
        require(burnableAmount > 0, 'Issuer: burnable is zero');

        uint256 newTotalDebt = totalDebt.sub(burnableAmount);
        uint256 newLastDebt = 0;

        if (newTotalDebt > 0) {
            uint256 delta = burnableAmount.preciseDivide(newTotalDebt);
            newLastDebt = lastDebt.preciseMultiply(PreciseMath.PRECISE_ONE().add(delta));
        }

        _setDebt(
            stake,
            account,
            currentPeriod,
            accountDebt.sub(burnableAmount),
            stakeDebt.sub(burnableAmount),
            newTotalDebt,
            newLastDebt,
            lastTime
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

    function getDebt(bytes32 stake, address account) external view returns (uint256) {
        uint256 currentPeriod = getCurrentPeriod();
        (uint256 debt, ) =
            _getDebt(stake, account, currentPeriod, Storage().getLastDebt(currentPeriod), getTotalDebt());
        return debt;
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
        (uint256 debtPercentage, ) = _getDebtPercentage(stake, account, period, Storage().getLastDebt(period));
        return debtPercentage;
    }

    function _canBurn(uint256 time) private view returns (bool) {
        return now >= time.add(Setting().getMinStakeTime());
    }

    function _getDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 lastDebt,
        uint256 totalDebt
    ) private view returns (uint256, uint256) {
        (uint256 debtPercentage, uint256 time) = _getDebtPercentage(stake, account, period, lastDebt);
        return (totalDebt.toPrecise().preciseMultiply(debtPercentage).toDecimal(), time);
    }

    function _getDebtPercentage(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 lastDebt
    ) private view returns (uint256, uint256) {
        (uint256 accountDebt, uint256 totalDebt, uint256 time) = Storage().getDebt(stake, account, period);
        if (time == 0) return (0, 0);
        return (lastDebt.preciseDivide(totalDebt).preciseMultiply(accountDebt), time);
    }

    function _setDebt(
        bytes32 stake,
        address account,
        uint256 period,
        uint256 accountDebt,
        uint256 stakeDebt,
        uint256 totalDebt,
        uint256 lastDebt,
        uint256 time
    ) private {
        Storage().setDebt(stake, account, period, accountDebt.preciseDivide(totalDebt), lastDebt, time);
        Storage().setDebt(stake, address(0), period, stakeDebt.preciseDivide(totalDebt), lastDebt, time);
    }
}
