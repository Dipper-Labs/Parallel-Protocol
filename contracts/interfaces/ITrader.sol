pragma solidity ^0.5.17;

interface ITrader {
    function trade(
        address account,
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    )
        external
        returns (
            uint256 tradingAmount,
            uint256 tradingFee,
            uint256 fromSynthPrice,
            uint256 toSynthPirce
        );

    function getTradingAmountAndFee(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    )
        external
        view
        returns (
            uint256 tradingAmount,
            uint256 tradingFee,
            uint256 fromSynthPrice,
            uint256 toSynthPirce,
            uint256 fromStatus,
            uint256 toStatus
        );

    function getTradingAmountAndFee(
        bytes32 fromSynth,
        bytes32 toSynth,
        uint256 toAmount
    )
        external
        view
        returns (
            uint256 tradingAmount,
            uint256 tradingFee,
            uint256 fromSynthPrice,
            uint256 toSynthPirce
        );

    function getTradingFee(address account, uint256 period) external view returns (uint256);

    function FEE_ADDRESS() external view returns (address);
}
