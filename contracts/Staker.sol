// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeERC20.sol';

import './base/Rewards.sol';
import './interfaces/IStaker.sol';
import './interfaces/storages/IStakerStorage.sol';
import './interfaces/IIssuer.sol';
import './interfaces/ISetting.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/IERC20.sol';

contract Staker is Rewards, IStaker {
    using SafeERC20 for IERC20;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_STAKER);
        imports = [
            CONTRACT_SYNTHX,
            CONTRACT_SUPPLY_SCHEDULE,
            CONTRACT_ISSUER,
            CONTRACT_SETTING,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SYNTHX_TOKEN
        ];
    }

    function Storage() private view returns (IStakerStorage) {
        return IStakerStorage(getStorage());
    }

    function Issuer() private view returns (IIssuer) {
        return IIssuer(requireAddress(CONTRACT_ISSUER));
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function AssetPrice() private view returns (IAssetPrice) {
        return IAssetPrice(requireAddress(CONTRACT_ASSET_PRICE));
    }

    function stake(
        bytes32 token,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNTHX) {
        Storage().incrementStaked(token, account, amount);
    }

    function unstake(
        bytes32 token,
        address account,
        uint256 amount
    ) external onlyAddress(CONTRACT_SYNTHX) {
        Storage().decrementStaked(token, account, amount, 'Staker: unstake amount exceeds staked');
    }

    function getStaked(bytes32 token, address account) public view returns (uint256) {
        uint256 staked = Storage().getStaked(token, account);
        return staked;
    }

    function getTransferable(bytes32 token, address account) external view returns (uint256 staker) {
        uint256 debt = Issuer().getDebt(token, account);
        uint256 price = AssetPrice().getPrice(token);
        uint256 staked = getStaked(token, account);
        uint256 collateralRate = Setting().getCollateralRate(token);
        uint256 stakeAmount = debt.decimalMultiply(collateralRate).decimalDivide(price);
        if (stakeAmount >= staked) return (0);

        uint256 transferable = staked.sub(stakeAmount);
        uint256 _staked = Storage().getStaked(token, account);
        if (transferable <= _staked) return transferable;

        return _staked;
    }

    function getCollateralRate(bytes32 token, address account) public view returns (uint256) {
        uint256 debt = Issuer().getDebt(token, account);
        uint256 price = AssetPrice().getPrice(token);
        uint256 staked = getStaked(token, account);
        return staked.decimalMultiply(price).decimalDivide(debt);
    }

    function claim(address account)
        external
        onlyAddress(CONTRACT_SYNTHX)
        returns (
            uint256 period,
            uint256 amount
        )
    {
        uint256 claimable = getClaimable(account);
        require(claimable > 0, 'Holder: claimable is zero');

        uint256 claimablePeriod = getClaimablePeriod();
        setClaimed(account, claimablePeriod, claimable);

        IERC20(requireAddress(CONTRACT_SYNTHX_TOKEN)).safeTransfer(account, claimable);
        return (claimablePeriod, claimable);
    }

    function getClaimable(address account) public view returns (uint256) {
        // TODO
        uint256 claimable = IERC20(requireAddress(CONTRACT_SYNTHX_TOKEN)).balanceOf(address(this));
        return claimable;
    }
}
