pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import '../../lib/Paging.sol';

interface ILiquidatorStorage {
    function addWatch(
        bytes32 stake,
        address account,
        uint256 time
    ) external;

    function removeWatch(bytes32 stake, address account) external;

    function getDeadline(bytes32 stake, address account) external view returns (uint256);

    function getAccounts(
        bytes32 stake,
        uint256 pageSize,
        uint256 pageNumber
    ) external view returns (address[] memory, Paging.Page memory);
}
