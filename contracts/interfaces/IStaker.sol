pragma solidity ^0.5.17;

interface IStaker {
    function stake(
        bytes32 token,
        address account,
        uint256 amount
    ) external;

    function unstake(
        bytes32 token,
        address account,
        uint256 amount
    ) external;

    function getStaked(bytes32 token, address account) external view returns (uint256);

    function getTransferable(bytes32 token, address account) external view returns (uint256 staker);

    function getCollateralRate(bytes32 token, address account) external view returns (uint256);
}
