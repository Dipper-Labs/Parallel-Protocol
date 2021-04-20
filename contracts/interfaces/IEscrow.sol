pragma solidity ^0.5.17;

interface IEscrow {
    function deposit(
        uint256 period,
        address account,
        uint256 amount
    ) external returns (uint256 vestTime);

    function deposit(
        uint256 period,
        address account,
        uint256 amount,
        uint256 vestTime
    ) external;

    function withdraw(address account, uint256 amount) external;

    function stake(address account, uint256 amount) external;

    function unstake(address account, uint256 amount) external;

    function getAvailable(address account) external view returns (uint256);

    function getWithdrawable(address account) external view returns (uint256);

    function getBalance(address account) external view returns (uint256);

    function getStaked(address account) external view returns (uint256);

    function escrowDuration() external view returns (uint256);

    event EscrowDurationChanged(uint256 indexed previousValue, uint256 indexed newValue);
}
