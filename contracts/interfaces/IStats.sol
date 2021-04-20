pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface IStats {
    struct Asset {
        bytes32 assetName;
        address assetAddress;
        bytes32 category;
        uint256 balance;
        uint256 price;
        uint256 status;
    }

    struct Vault {
        bytes32 assetName;
        address assetAddress;
        uint256 currentCollateralRate;
        uint256 rewardCollateralRate;
        uint256 liquidationCollateralRate;
        uint256 liquidationFeeRate;
        uint256 staked;
        uint256 debt;
        uint256 transferable;
        uint256 balance;
        uint256 price;
    }

    struct Reward {
        bytes32 reward;
        bytes32 token;
        bytes32 asset;
        uint256 amount;
        uint256 time;
    }

    struct Pair {
        bytes32 fromAsset;
        uint256 fromAssetPrice;
        bytes32 toAsset;
        uint256 toAssetPrice;
        bytes32 category;
        uint256 open;
        uint256 last;
        uint256 low;
        uint256 hight;
        uint256 volume;
        uint256 turnover;
        uint256 status;
    }

    function getBalance(address account) external view returns (Asset[] memory);

    function getAsset(
        bytes32 assetType,
        bytes32 assetName,
        address account
    ) external view returns (Asset memory);

    function getAssets(bytes32 assetType, address account) external view returns (Asset[] memory);

    function getVault(bytes32 stake, address account) external view returns (Vault memory);

    function getVaults(address account) external view returns (Vault[] memory);

    function getTotalCollateral(address account)
        external
        view
        returns (
            uint256 totalCollateralRatio,
            uint256 totalCollateralValue,
            uint256 totalDebt
        );

    function getEscrowed(address account) external view returns (uint256 total, uint256 staked);

    function getLocked(
        bytes32 asset,
        address account,
        bool isPool
    ) external view returns (uint256);

    function getAvailable(bytes32 stake, address account)
        external
        view
        returns (
            uint256 balance,
            uint256 escrowed,
            uint256 transferable
        );

    function getSynthValue(address account) external view returns (uint256);

    function getTradingAmountAndFee(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    ) external view returns (uint256 tradingAmount, uint256 tradingFee);

    function getTradingAmountAndFee(
        bytes32 fromSynth,
        bytes32 toSynth,
        uint256 toAmount
    ) external view returns (uint256 tradingAmount, uint256 tradingFee);

    function getWithdrawable(address account) external view returns (uint256);

    function getRewards(address account) external view returns (Reward[] memory);

    function getRewardTokens(bytes32 assetType) external view returns (Reward[] memory);

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
        );

    function getLine(bytes32 asset, uint256 size) external view returns (uint256[] memory);

    function getPair(bytes32 fromAsset, bytes32 toAsset) external view returns (Pair memory);

    function getPairs() external view returns (Pair[] memory);

    function getTradingFee(address account, uint256 period) external view returns (uint256);

    function getDebtPercentage(
        bytes32 stake,
        address account,
        uint256 period
    ) external view returns (uint256);

    function getPeriodLocked(
        bytes32 asset,
        address account,
        uint256 period,
        bool isPool
    ) external view returns (uint256);
}
