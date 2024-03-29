pragma solidity ^0.5.16;

// Inheritance
import "./interfaces/IERC20.sol";
import "./ExternStateToken.sol";
import "./MixinResolver.sol";
import "./interfaces/ISynthetix.sol";

// Internal references
import "./interfaces/ISynth.sol";
import "./TokenState.sol";
import "./interfaces/ISynthetixState.sol";
import "./interfaces/ISystemStatus.sol";
import "./interfaces/IExchanger.sol";
import "./interfaces/IIssuer.sol";
import "./interfaces/IStaker.sol";
import "./interfaces/IRewardsDistribution.sol";
import "./interfaces/IVirtualSynth.sol";


contract BaseSynthetix is IERC20, ExternStateToken, MixinResolver, ISynthetix {
    // ========== STATE VARIABLES ==========

    // Available Synths which can be used with the system
    string public constant TOKEN_NAME = "DIPSYN Network Token";
    string public constant TOKEN_SYMBOL = "SNX";
    uint8 public constant DECIMALS = 18;
    bytes32 public constant sUSD = "sUSD";


    bytes32 public nativeCoin;

    // ========== ADDRESS RESOLVER CONFIGURATION ==========
    bytes32 private constant CONTRACT_SYNTHETIXSTATE = "SynthetixState";
    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_STAKER = "Staker";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";

    // ========== CONSTRUCTOR ==========

    constructor(
        address payable _proxy,
        TokenState _tokenState,
        address _owner,
        uint _totalSupply,
        IAddressResolver _resolver,
        bytes32 _nativeCoin
    )
        public
        ExternStateToken(_proxy, _tokenState, TOKEN_NAME, TOKEN_SYMBOL, _totalSupply, DECIMALS, _owner)
        MixinResolver(_resolver)
    {
        nativeCoin = _nativeCoin;
    }

    // ========== VIEWS ==========

    // Note: use public visibility so that it can be invoked in a subclass
    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](5);
        addresses[0] = CONTRACT_SYNTHETIXSTATE;
        addresses[1] = CONTRACT_SYSTEMSTATUS;
        addresses[2] = CONTRACT_EXCHANGER;
        addresses[3] = CONTRACT_ISSUER;
        addresses[4] = CONTRACT_STAKER;
        addresses[5] = CONTRACT_REWARDSDISTRIBUTION;
    }

    function synthetixState() internal view returns (ISynthetixState) {
        return ISynthetixState(requireAndGetAddress(CONTRACT_SYNTHETIXSTATE));
    }

    function systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function staker() internal view returns (IStaker) {
        return IStaker(requireAndGetAddress(CONTRACT_STAKER));
    }

    function rewardsDistribution() internal view returns (IRewardsDistribution) {
        return IRewardsDistribution(requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION));
    }

    function debtBalanceOf(bytes32 token, address account, bytes32 currencyKey) external view returns (uint) {
        return issuer().debtBalanceOf(token, account, currencyKey);
    }

    function totalIssuedSynths(bytes32 currencyKey) external view returns (uint) {
        return issuer().totalIssuedSynths(currencyKey);
    }

    function availableCurrencyKeys() external view returns (bytes32[] memory) {
        return issuer().availableCurrencyKeys();
    }

    function availableSynthCount() external view returns (uint) {
        return issuer().availableSynthCount();
    }

    function availableSynths(uint index) external view returns (ISynth) {
        return issuer().availableSynths(index);
    }

    function synths(bytes32 currencyKey) external view returns (ISynth) {
        return issuer().synths(currencyKey);
    }

    function synthsByAddress(address synthAddress) external view returns (bytes32) {
        return issuer().synthsByAddress(synthAddress);
    }

    function asset(bytes32 currencyKey) external view returns (address) {
        return staker().getAsset(currencyKey);
    }

    function assetByAddress(address assetAddress) external view returns (bytes32) {
        return staker().getAssetByAddress(assetAddress);
    }

    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool) {
        return exchanger().maxSecsLeftInWaitingPeriod(messageSender, currencyKey) > 0;
    }

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid) {
        return issuer().anySynthOrSNXRateIsInvalid();
    }

    function maxIssuableSynths(address account) external view returns (uint maxIssuable) {
        return issuer().maxIssuableSynths(account);
    }

    function remainingIssuableSynths(address account)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        )
    {
        return issuer().remainingIssuableSynths(account);
    }

    function collateralisationRatio(bytes32 token, address _issuer) external view returns (uint) {
        return issuer().collateralisationRatio(token, _issuer);
    }

    function collateral(bytes32 token, address account) external view returns (uint) {
        return issuer().collateral(token, account);
    }

    function transferableSynthetix(address account) external view returns (uint transferable) {
        (transferable, ) = issuer().transferableSynthetixAndAnyRateIsInvalid(account, tokenState.balanceOf(account));
    }

    function _canTransfer(address account, uint value) internal view returns (bool) {
        (uint initialDebtOwnership, ) = synthetixState().issuanceData(account);

        if (initialDebtOwnership > 0) {
            (uint transferable, bool anyRateIsInvalid) = issuer().transferableSynthetixAndAnyRateIsInvalid(
                account,
                tokenState.balanceOf(account)
            );
            require(value <= transferable, "Cannot transfer staked or escrowed SNX");
            require(!anyRateIsInvalid, "A synth or SNX rate is invalid");
        }
        return true;
    }

    // ========== MUTATIVE FUNCTIONS ==========

    function transfer(address to, uint value) external optionalProxy systemActive returns (bool) {
        // Ensure they're not trying to exceed their locked amount -- only if they have debt.
        _canTransfer(messageSender, value);

        // Perform the transfer: if there is a problem an exception will be thrown in this call.
        _transferByProxy(messageSender, to, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) external optionalProxy systemActive returns (bool) {
        // Ensure they're not trying to exceed their locked amount -- only if they have debt.
        _canTransfer(from, value);

        // Perform the transfer: if there is a problem,
        // an exception will be thrown in this call.
        return _transferFromByProxy(messageSender, from, to, value);
    }

    function issueSynths(bytes32 stake, uint amount, uint synthAmount) external issuanceActive optionalProxy {
        IERC20 token = IERC20(staker().requireAsset(stake));
        require(token.transferFrom(messageSender, address(this), amount), 'Base synth: transferFrom failed!');

        return issuer().issueSynths(stake, messageSender, amount, synthAmount);
    }

    function issueSynthsOnBehalf(bytes32 stake, address issueForAddress, uint amount, uint synthAmount) external issuanceActive optionalProxy {
        return issuer().issueSynthsOnBehalf(stake, issueForAddress, messageSender, amount, synthAmount);
    }

    function issueMaxSynths(bytes32 stake) external issuanceActive optionalProxy {
        return issuer().issueMaxSynths(stake, messageSender);
    }

    function issueMaxSynthsOnBehalf(bytes32 stake, address issueForAddress) external issuanceActive optionalProxy {
        return issuer().issueMaxSynthsOnBehalf(stake, issueForAddress, messageSender);
    }

    function burnSynths(bytes32 stake, uint amount) external issuanceActive optionalProxy {
        return issuer().burnSynths(stake, messageSender, amount);
    }

    function burnSynthsOnBehalf(bytes32 stake, address burnForAddress, uint amount) external issuanceActive optionalProxy {
        return issuer().burnSynthsOnBehalf(stake, burnForAddress, messageSender, amount);
    }

    function burnSynthsToTarget(bytes32 stake) external issuanceActive optionalProxy {
        return issuer().burnSynthsToTarget(stake, messageSender);
    }

    function burnSynthsToTargetOnBehalf(bytes32 stake, address burnForAddress) external issuanceActive optionalProxy {
        return issuer().burnSynthsToTargetOnBehalf(stake, burnForAddress, messageSender);
    }

    function exchange(
        bytes32,
        uint,
        bytes32
    ) external returns (uint) {
        _notImplemented();
    }

    function exchangeOnBehalf(
        address,
        bytes32,
        uint,
        bytes32
    ) external returns (uint) {
        _notImplemented();
    }



    function exchangeWithVirtual(
        bytes32,
        uint,
        bytes32
    ) external returns (uint, IVirtualSynth) {
        _notImplemented();
    }

    function settle(bytes32)
        external
        returns (
            uint,
            uint,
            uint
        )
    {
        _notImplemented();
    }

    function mint() external returns (bool) {
        _notImplemented();
    }

    function liquidateDelinquentAccount(address, uint) external returns (bool) {
        _notImplemented();
    }

    function mintSecondary(address, uint) external {
        _notImplemented();
    }

    function mintSecondaryRewards(uint) external {
        _notImplemented();
    }

    function burnSecondary(address, uint) external {
        _notImplemented();
    }

    function _notImplemented() internal pure {
        revert("Cannot be run on this layer");
    }

    // ========== MODIFIERS ==========

    modifier systemActive() {
        _systemActive();
        _;
    }

    function _systemActive() private view {
        systemStatus().requireSystemActive();
    }

    modifier issuanceActive() {
        _issuanceActive();
        _;
    }

    function _issuanceActive() private view {
        systemStatus().requireIssuanceActive();
    }
}
