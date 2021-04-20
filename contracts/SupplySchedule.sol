// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './base/Importable.sol';
import './interfaces/ISetting.sol';
import './interfaces/IEscrow.sol';
import './interfaces/IHistory.sol';

contract SupplySchedule is Importable, ISupplySchedule {
    using SafeMath for uint256;
    using PreciseMath for uint256;

    uint256[] public SUPPLY_SCHEDULE = [9000E22, 6222E22, 4012E22, 2444E22, 1228E22, 200E22];

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
            CONTRACT_SYNBIT_TOKEN,
            CONTRACT_SETTING,
            CONTRACT_ESCROW,
            CONTRACT_TRADER,
            CONTRACT_HOLDER,
            CONTRACT_TEAM,
            CONTRACT_HISTORY
        ];

        startMintTime = (_startMintTime == 0) ? now : _startMintTime;
        lastMintTime = (_lastMintTime < startMintTime) ? startMintTime : _lastMintTime;

        percentages[CONTRACT_STAKER] = 0.5 ether; // 50%
        percentages[CONTRACT_SPECIAL] = 0.12 ether; // 12%
        percentages[CONTRACT_PROVIDER] = 0.16 ether; // 16%
        percentages[CONTRACT_TRADER] = 0.1 ether; // 10%
        percentages[CONTRACT_HOLDER] = 0.02 ether; // 2%
        percentages[CONTRACT_TEAM] = 0.1 ether; // 10%
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function setPercentage(bytes32 recipient, uint256 percent) external onlyOwner {
        require(_isRecipient(recipient), 'SupplySchedule: invalid recipient');
        require(recipient != CONTRACT_STAKER, 'SupplySchedule: invalid recipient');

        emit SupplyPercentageChanged(recipient, percentages[recipient], percent);
        percentages[recipient] = percent;
        uint256 totalPercentage = _getTotalPercentageWithoutStaker();
        require(
            totalPercentage <= PreciseMath.DECIMAL_ONE(),
            'SupplySchedule: total percent must be no greater than 100%'
        );
        percentages[CONTRACT_STAKER] = PreciseMath.DECIMAL_ONE().sub(totalPercentage);
    }

    function _isRecipient(bytes32 recipient) private pure returns (bool) {
        return (recipient == CONTRACT_TRADER ||
            recipient == CONTRACT_HOLDER ||
            recipient == CONTRACT_TEAM ||
            recipient == CONTRACT_PROVIDER ||
            recipient == CONTRACT_SPECIAL ||
            recipient == CONTRACT_STAKER);
    }

    function _getTotalPercentageWithoutStaker() private view returns (uint256) {
        return
            percentages[CONTRACT_TRADER]
                .add(percentages[CONTRACT_HOLDER])
                .add(percentages[CONTRACT_TEAM])
                .add(percentages[CONTRACT_PROVIDER])
                .add(percentages[CONTRACT_SPECIAL]);
    }

    function distributeSupply()
        external
        onlyAddress(CONTRACT_SYNBIT_TOKEN)
        returns (address[] memory recipients, uint256[] memory amounts)
    {
        if (now < nextMintTime()) return (recipients, amounts);

        uint256 currentPeriod = currentPeriod();
        uint256 lastMintPeriod = lastMintPeriod();

        uint256 totalSupply = 0;
        uint256 traderSupply = 0;
        uint256 holderSupply = 0;
        uint256 teamSupply = 0;
        uint256 escrowSupply = 0;

        for (uint256 i = lastMintPeriod; i < currentPeriod; i++) {
            uint256 supply = periodSupply(i);

            uint256 traderPeriodSupply = supply.decimalMultiply(percentages[CONTRACT_TRADER]);
            uint256 holderPeriodSupply = supply.decimalMultiply(percentages[CONTRACT_HOLDER]);
            uint256 escrowPeriodSupply = supply.sub(traderSupply).sub(holderSupply);

            traderSupply = traderSupply.add(traderPeriodSupply);
            holderSupply = holderSupply.add(holderPeriodSupply);
            escrowSupply = escrowSupply.add(escrowPeriodSupply);
            teamSupply = teamSupply.add(supply.decimalMultiply(percentages[CONTRACT_TEAM]));
            totalSupply = totalSupply.add(traderSupply).add(holderSupply).add(escrowSupply);
        }

        if (totalSupply == 0) return (recipients, amounts);

        recipients = new address[](3);
        recipients[0] = requireAddress(CONTRACT_TRADER);
        recipients[1] = requireAddress(CONTRACT_HOLDER);
        recipients[2] = requireAddress(CONTRACT_ESCROW);
        amounts = new uint256[](3);
        amounts[0] = traderSupply;
        amounts[1] = holderSupply;
        amounts[2] = escrowSupply;

        address teamAddress = requireAddress(CONTRACT_TEAM);

        uint256 vestTime = Escrow().deposit(lastMintPeriod, teamAddress, teamSupply);
        History().addAction('Claim', teamAddress, CONTRACT_SUPPLY_SCHEDULE, SYN, vestTime, SYN, teamSupply);
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
