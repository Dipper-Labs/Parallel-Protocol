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

    constructor(
        IResolver _resolver,
        uint256 _startMintTime,
        uint256 _lastMintTime
    ) public Importable(_resolver) {
        setContractName(CONTRACT_SUPPLY_SCHEDULE);
        imports = [
            CONTRACT_SYNTHX_TOKEN,
            CONTRACT_SETTING,
            CONTRACT_HOLDER,
            CONTRACT_TRADER,
            CONTRACT_TEAM,
            CONTRACT_HISTORY
        ];

        startMintTime = (_startMintTime == 0) ? now : _startMintTime;
        lastMintTime = (_lastMintTime < startMintTime) ? startMintTime : _lastMintTime;

        percentages[CONTRACT_HOLDER] = 0.8 ether; // 80%
        percentages[CONTRACT_TEAM] = 0.15 ether; // 15%
        percentages[CONTRACT_TRADER] = 0.01 ether; // 1%
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }


    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function setPercentage(bytes32 recipient, uint256 percent) external onlyOwner {
        require(_isRecipient(recipient), 'SupplySchedule: invalid recipient');
        require(recipient != CONTRACT_HOLDER, 'SupplySchedule: invalid recipient');

        emit SupplyPercentageChanged(recipient, percentages[recipient], percent);
        percentages[recipient] = percent;
        uint256 totalPercentage = _getTotalPercentageWithoutStaker();
        require(
            totalPercentage <= PreciseMath.DECIMAL_ONE(),
            'SupplySchedule: total percent must be no greater than 100%'
        );
        percentages[CONTRACT_HOLDER] = PreciseMath.DECIMAL_ONE().sub(totalPercentage);
    }

    function _isRecipient(bytes32 recipient) private pure returns (bool) {
        return (recipient == CONTRACT_TRADER ||
            recipient == CONTRACT_TEAM ||
            recipient == CONTRACT_HOLDER);
    }

    function _getTotalPercentageWithoutStaker() private view returns (uint256) {
        return
            percentages[CONTRACT_TRADER]
                .add(percentages[CONTRACT_TEAM]);
    }

    function distributeSupply()
        external
        onlyAddress(CONTRACT_SYNTHX_TOKEN)
        returns (address[] memory recipients, uint256[] memory amounts)
    {
        if (now < nextMintTime()) return (recipients, amounts);

        recipients = new address[](1);
        recipients[0] = requireAddress(CONTRACT_HOLDER);
        amounts = new uint256[](2);
        amounts[0] = 1e19;

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

    function currentPeriod() public view returns (uint256) {
        return _getPeriod(now);
    }

    function lastMintPeriod() public view returns (uint256) {
        return _getPeriod(lastMintTime);
    }

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
