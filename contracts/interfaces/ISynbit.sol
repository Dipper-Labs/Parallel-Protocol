pragma solidity ^0.5.17;

interface ISynbit {
    function nativeCoin() external view returns (bytes32);

    function stakeFromCoin() external payable returns (bool);

    function stakeFromEscrow(uint256 amount) external returns (bool);

    function stakeFromToken(bytes32 stake, uint256 amount) external returns (bool);

    function mintFromCoin() external payable returns (bool);

    function mintFromEscrow(uint256 amount) external returns (bool);

    function mintFromToken(bytes32 stake, uint256 amount) external returns (bool);

    function mintFromTransferable(bytes32 stake, uint256 amount) external returns (bool);

    function burn(bytes32 stake, uint256 amount) external returns (bool);

    function transfer(
        bytes32 stake,
        address payable recipient,
        uint256 amount
    ) external returns (bool);

    function trade(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    ) external returns (bool);

    function lock(
        bytes32 asset,
        uint256 amount,
        bool isPool
    ) external returns (bool);

    function unlock(
        bytes32 asset,
        uint256 amount,
        bool isPool
    ) external returns (bool);

    function claim(bytes32 reward, bytes32 asset) external returns (bool);

    function vest(uint256 amount) external returns (bool);

    function liquidate(
        bytes32 stake,
        address account,
        uint256 amount
    ) external returns (bool);

    event Staked(address indexed account, bytes32 indexed from, bytes32 indexed stake, uint256 stakeAmount);
    event Minted(
        address indexed account,
        bytes32 indexed from,
        bytes32 indexed stake,
        uint256 stakeAmount,
        uint256 issuerAmount
    );
    event Burned(address indexed account, bytes32 indexed stake, uint256 amount);
    event Transfered(address indexed account, bytes32 indexed stake, address indexed recipient, uint256 amount);
    event Traded(
        address indexed account,
        bytes32 indexed fromSynth,
        bytes32 indexed toSynth,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 tradingFee,
        uint256 fromSynthPrice,
        uint256 toSynthPirce
    );
    event Locked(address indexed account, bytes32 indexed asset, uint256 amount, bool isPool);
    event Unlocked(address indexed account, bytes32 indexed asset, uint256 amount, bool isPool);
    event Claimed(
        address indexed account,
        bytes32 indexed reward,
        bytes32 indexed asset,
        uint256 period,
        uint256 amount,
        uint256 vestTime
    );
    event Vested(address indexed account, uint256 amount);
    event Liquidated(
        address indexed liquidator,
        bytes32 indexed stake,
        address indexed account,
        uint256 stakeAmount,
        uint256 burnAmount
    );
}
