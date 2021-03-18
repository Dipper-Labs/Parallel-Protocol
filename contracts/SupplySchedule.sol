pragma solidity ^0.5.16;

// Inheritance
import "./Owned.sol";
import "./interfaces/ISupplySchedule.sol";

// Libraries
import "./SafeDecimalMath.sol";
import "./Math.sol";

// Internal references
import "./Proxy.sol";
import "./interfaces/ISynthetix.sol";
import "./interfaces/IERC20.sol";


contract SupplySchedule is Owned, ISupplySchedule {
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using Math for uint;

    // Time of the last inflation supply mint event
    uint public lastMintEvent;

    // Counter for number of days since the start of supply inflation
    uint public dayCounter;

    uint public constant DAYS_PER_YEAR = 365;

    // The number of SDIP rewarded to the caller of Synthetix.mint()
    uint public minterReward = 20 * SafeDecimalMath.unit();

    // The initial daily inflationary supply
    uint public constant INITIAL_DAILY_SUPPLY = 864000 * 1e18;

    // Address of the SynthetixProxy for the onlySynthetix modifier
    address payable public synthetixProxy;

    // Max SDIP rewards for minter
    uint public constant MAX_MINTER_REWARD = 200 * 1e18;

    // How long each inflation period is before mint can be called
    uint public constant MINT_PERIOD_DURATION = 1 days;

    uint public constant INFLATION_START_DATE = 1551830400; // 2019-03-06T00:00:00+00:00

    // Yearly percentage decay of inflationary supply
    uint public constant DECAY_RATE = 500000000000000000; // 50% yearly

    constructor(
        address _owner,
        uint _lastMintEvent
    ) public Owned(_owner) {
        lastMintEvent = _lastMintEvent;
        dayCounter = 0;
    }

    // ========== VIEWS ==========

    /**
     * @return The amount of SNX mintable for the inflationary supply
     */
    function mintableSupply() external view returns (uint) {
        uint totalAmount;

        if (!isMintable()) {
            return totalAmount;
        }

        uint currentDay = dayCounter;
        uint remainingDaysToMint = daysSinceLastIssuance();
        // Calculate total mintable supply from exponential decay function
        while (remainingDaysToMint > 0) {
            currentDay++;
            uint daySupply = getDaySupply(currentDay);
            totalAmount = totalAmount.add(daySupply);
            remainingDaysToMint--;
        }

        return totalAmount;
    }

    function getDaySupply(uint _dayCounter) internal view returns (uint) {
        uint numOfYears = _dayCounter.div(DAYS_PER_YEAR);
        uint effectiveDecay = (SafeDecimalMath.unit().sub(DECAY_RATE)).powDecimal(numOfYears);
        uint supplyForDay = INITIAL_DAILY_SUPPLY.multiplyDecimal(effectiveDecay);
        return supplyForDay;
    }

    /**
     * @dev Take timeDiff in seconds (Dividend) and MINT_PERIOD_DURATION as (Divisor)
     * @return Calculate the numberOfDays since last mint rounded down to 1 day
     */
    function daysSinceLastIssuance() public view returns (uint) {
        // Get days since lastMintEvent
        // If lastMintEvent not set or 0, then start from inflation start date.
        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(INFLATION_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    /**
     * @return boolean whether the MINT_PERIOD_DURATION (1 days)
     * has passed since the lastMintEvent.
     * */
    function isMintable() public view returns (bool) {
        if (now - lastMintEvent > MINT_PERIOD_DURATION) {
            return true;
        }
        return false;
    }

    // ========== MUTATIVE FUNCTIONS ==========

    /**
     * @notice Record the mint event from Synthetix by incrementing the inflation
     * week counter for the number of weeks minted (probabaly always 1)
     * and store the time of the event.
     * @param supplyMinted the amount of SNX the total supply was inflated by.
     * */
    function recordMintEvent(uint supplyMinted) external onlySynthetix returns (bool) {
        uint numberOfDaysIssued = daysSinceLastIssuance();

        // add number of weeks minted to dayCounter
        dayCounter = dayCounter.add(numberOfDaysIssued);

        // Update mint event to latest day issued (start date + number of days issued * seconds in day)
        lastMintEvent = INFLATION_START_DATE.add(dayCounter.mul(MINT_PERIOD_DURATION));

        emit SupplyMinted(supplyMinted, numberOfDaysIssued, lastMintEvent, now);
        return true;
    }

    /**
     * @notice Sets the reward amount of SNX for the caller of the public
     * function Synthetix.mint().
     * This incentivises anyone to mint the inflationary supply and the mintr
     * Reward will be deducted from the inflationary supply and sent to the caller.
     * @param amount the amount of SNX to reward the minter.
     * */
    function setMinterReward(uint amount) external onlyOwner {
        require(amount <= MAX_MINTER_REWARD, "Reward cannot exceed max minter reward");
        minterReward = amount;
        emit MinterRewardUpdated(minterReward);
    }

    // ========== SETTERS ========== */

    /**
     * @notice Set the SynthetixProxy should it ever change.
     * SupplySchedule requires Synthetix address as it has the authority
     * to record mint event.
     * */
    function setSynthetixProxy(ISynthetix _synthetixProxy) external onlyOwner {
        require(address(_synthetixProxy) != address(0), "Address cannot be 0");
        synthetixProxy = address(uint160(address(_synthetixProxy)));
        emit SynthetixProxyUpdated(synthetixProxy);
    }

    // ========== MODIFIERS ==========

    /**
     * @notice Only the Synthetix contract is authorised to call this function
     * */
    modifier onlySynthetix() {
        require(
            msg.sender == address(Proxy(address(synthetixProxy)).target()),
            "Only the synthetix contract can perform this action"
        );
        _;
    }

    /* ========== EVENTS ========== */
    /**
     * @notice Emitted when the inflationary supply is minted
     * */
    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    /**
     * @notice Emitted when the SNX minter reward amount is updated
     * */
    event MinterRewardUpdated(uint newRewardAmount);

    /**
     * @notice Emitted when setSynthetixProxy is called changing the Synthetix Proxy address
     * */
    event SynthetixProxyUpdated(address newAddress);
}
