// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './base/Importable.sol';
import './interfaces/ISetting.sol';
import './interfaces/IHistory.sol';

contract SupplySchedule is Importable, ISupplySchedule {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    // 315360000 = 30 * 20(20blocks/minute) * 60 * 24 * 365
    uint256[] public SUPPLY_SCHEDULE = [31536E22, 15768E22, 7884E22, 3942E22, 1971E22, 9855E21];

    uint256 public startMintTime;
    uint256 public lastMintTime;
    mapping(bytes32 => uint256) public percentages;

    constructor(IResolver _resolver, uint256 _startMintTime, uint256 _lastMintTime) public Importable(_resolver) {
        setContractName(CONTRACT_SUPPLY_SCHEDULE);
        imports = [CONTRACT_SYNTHX_TOKEN, CONTRACT_SETTING, CONTRACT_FOUNDATION, CONTRACT_ECOLOGY, CONTRACT_HOLDER, CONTRACT_HISTORY];

        startMintTime = (_startMintTime == 0) ? now : _startMintTime;
        lastMintTime = (_lastMintTime < startMintTime) ? startMintTime : _lastMintTime;

        percentages[CONTRACT_HOLDER] = 0.8 ether; // 80%
        percentages[CONTRACT_FOUNDATION] = 0.15 ether; // 15%
        percentages[CONTRACT_ECOLOGY] = 0.05 ether; // 5%
    }

    function Setting() private view returns (ISetting) {return ISetting(requireAddress(CONTRACT_SETTING));}

    function History() private view returns (IHistory) {return IHistory(requireAddress(CONTRACT_HISTORY));}

    function setPercentage(bytes32 recipient, uint256 percent) external onlyOwner {
        require(_isRecipient(recipient), 'SupplySchedule: invalid recipient');
        require(recipient != CONTRACT_HOLDER, 'SupplySchedule: invalid recipient');

        emit SupplyPercentageChanged(recipient, percentages[recipient], percent);
        percentages[recipient] = percent;
        uint256 totalPercentage = _getTotalPercentageWithoutStaker();
        require(totalPercentage <= PreciseMath.DECIMAL_ONE(), 'SupplySchedule: total percent must be no greater than 100%');
        percentages[CONTRACT_HOLDER] = PreciseMath.DECIMAL_ONE().sub(totalPercentage);
    }

    function _isRecipient(bytes32 recipient) private pure returns (bool) {
        return (recipient == CONTRACT_FOUNDATION || recipient == CONTRACT_HOLDER || recipient == CONTRACT_ECOLOGY);
    }

    function _getTotalPercentageWithoutStaker() private view returns (uint256) {
        return percentages[CONTRACT_FOUNDATION].add(percentages[CONTRACT_ECOLOGY]);
    }

    function distributeSupply() external onlyAddress(CONTRACT_SYNTHX_TOKEN) returns (address[] memory recipients, uint256[] memory amounts) {
        if (now < nextMintTime()) return (recipients, amounts);

        uint256 currentPeriod = currentPeriod();
        uint256 lastMintPeriod = lastMintPeriod();

        uint256 totalSupply = 0;
        uint256 stakerSupply = 0;
        uint256 foundationSupply = 0;
        uint256 ecologySupply = 0;

        for (uint256 i = lastMintPeriod; i < currentPeriod; i++) {
            uint256 supply = periodSupply(i);

            uint256 stakerPeriodSupply = supply.decimalMultiply(percentages[CONTRACT_HOLDER]);
            uint256 foundationPeriodSupply = supply.decimalMultiply(percentages[CONTRACT_FOUNDATION]);
            uint256 ecologyPeriodSupply = supply.sub(stakerPeriodSupply).sub(foundationPeriodSupply);

            stakerSupply = stakerSupply.add(stakerPeriodSupply);
            foundationSupply = foundationSupply.add(foundationPeriodSupply);
            ecologySupply = ecologySupply.add(ecologyPeriodSupply);
            totalSupply = totalSupply.add(supply);
        }

        if (totalSupply == 0) return (recipients, amounts);

        recipients = new address[](3);
        recipients[0] = requireAddress(CONTRACT_HOLDER);
        recipients[1] = requireAddress(CONTRACT_FOUNDATION);
        recipients[2] = requireAddress(CONTRACT_ECOLOGY);

        amounts = new uint256[](3);
        amounts[0] = stakerSupply;
        amounts[1] = foundationSupply;
        amounts[2] = ecologySupply;

        lastMintTime = now;
    }

    function mintableSupply(bytes32 recipient, uint256 period) external view returns (uint256) {
        if (lastMintPeriod() <= period) return 0;
        return periodSupply(recipient, period);
    }

    function periodSupply(bytes32 recipient, uint256 period) public view returns (uint256) {
        return periodSupply(period).decimalMultiply(percentages[recipient]);
    }

    function periodSupply(uint256 period) public view returns (uint256) {
        uint256 yearlyPeriods = _getYearlyPeriods();
        uint256 year = period.div(yearlyPeriods);
        if (year >= SUPPLY_SCHEDULE.length) year = SUPPLY_SCHEDULE.length.sub(1);
        return SUPPLY_SCHEDULE[year].div(yearlyPeriods);
    }

    function currentPeriod() public view returns (uint256) {return _getPeriod(now);}

    function lastMintPeriod() public view returns (uint256) {return _getPeriod(lastMintTime);}

    function nextMintTime() public view returns (uint256) {
        return lastMintTime.add(Setting().getMintPeriodDuration());
    }

    function _getPeriod(uint256 timestamp) private view returns (uint256) {
        if (timestamp <= startMintTime) return 0;
        return timestamp.sub(startMintTime).div(Setting().getMintPeriodDuration());
    }

    function _getYearlyPeriods() private view returns (uint256) {
        uint256 year = 365 days;
        return year.div(Setting().getMintPeriodDuration());
    }
}
