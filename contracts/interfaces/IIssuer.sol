pragma solidity ^0.5.17;

interface IIssuer {
    function issueDebt(bytes32 stake, address account, uint256 amount, uint256 dTokenMintedAmount) external;

    function burnDebt(bytes32 stake, address account, uint256 dTokenBurnedAmount, uint256 usdtAmount, address payer) external returns (uint256);

    function issueSynth(bytes32 synth, address account, uint256 amount) external;

    function burnSynth(bytes32 synth, address account, uint256 amount) external;

    function getDebt(bytes32 stake, address account) external view returns (uint256, uint256);

    function getTotalDebt() external view returns (uint256);

    function getDebtPercentage(bytes32 stake, address account, uint256 period) external view returns (uint256);
}
