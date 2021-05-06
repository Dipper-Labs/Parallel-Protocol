// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/SafeERC20.sol';
import './base/Proxyable.sol';
import './base/Pausable.sol';
import './base/Importable.sol';
import './interfaces/ISynthx.sol';
import './interfaces/IStaker.sol';
import './interfaces/ITrader.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/ISetting.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IRewards.sol';
import './interfaces/ISynthxToken.sol';
import './interfaces/ISynthxDToken.sol';
import './interfaces/IMarket.sol';
import './interfaces/IHistory.sol';
import './interfaces/ILiquidator.sol';
import './interfaces/IERC20.sol';

contract Synthx is Proxyable, Pausable, Importable, ISynthx {
    using SafeMath for uint256;
    using PreciseMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 private constant FROM_BALANCE = 'FromBalance';
    bytes32 private constant FROM_TRANSFERABLE = 'FromTransferable';

    bytes32 public nativeCoin;

    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver, bytes32 _nativeCoin) external onlyOwner returns (bool) {
        setInitialized();
        resolver = _resolver;
        nativeCoin = _nativeCoin;
        setContractName(CONTRACT_SYNTHX);
        imports = [
            CONTRACT_STAKER,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SETTING,
            CONTRACT_ISSUER,
            CONTRACT_TRADER,
            CONTRACT_SYNTHX_TOKEN,
            CONTRACT_SYNTHX_DTOKEN,
            CONTRACT_MARKET,
            CONTRACT_HISTORY,
            CONTRACT_LIQUIDATOR
        ];
        return true;
    }

    function Staker() private view returns (IStaker) {
        return IStaker(requireAddress(CONTRACT_STAKER));
    }

    function AssetPrice() private view returns (IAssetPrice) {
        return IAssetPrice(requireAddress(CONTRACT_ASSET_PRICE));
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Issuer() private view returns (IIssuer) {
        return IIssuer(requireAddress(CONTRACT_ISSUER));
    }

    function Trader() private view returns (ITrader) {
        return ITrader(requireAddress(CONTRACT_TRADER));
    }

    function Rewards(bytes32 reward) private view returns (IRewards) {
        return IRewards(requireAddress(reward));
    }

    function SynthxToken() private view returns (ISynthxToken) {
        return ISynthxToken(requireAddress(CONTRACT_SYNTHX_TOKEN));
    }

    function SynthxDToken() private view returns (ISynthxDToken) {
        return ISynthxDToken(requireAddress(CONTRACT_SYNTHX_DTOKEN));
    }

    function Market() private view returns (IMarket) {
        return IMarket(requireAddress(CONTRACT_MARKET));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function Liquidator() private view returns (ILiquidator) {
        return ILiquidator(requireAddress(CONTRACT_LIQUIDATOR));
    }

    function stakeFromCoin() external payable returns (bool) {
        require(Issuer().getDebt(nativeCoin, msg.sender) > 0, 'Synthx: Debt must be greater than zero');

        _stake(nativeCoin, msg.value, FROM_BALANCE);
        History().addAction('Stake', msg.sender, 'Stake', nativeCoin, msg.value, bytes32(0), 0);
        Liquidator().watchAccount(nativeCoin, msg.sender);
//        SynthxToken().mint();
        emit Staked(msg.sender, FROM_BALANCE, nativeCoin, msg.value);
        return true;
    }

    function stakeFromToken(bytes32 stake, uint256 amount) external returns (bool) {
        require(stake != nativeCoin, 'Synthx: Native Coin use "mintFromCoin" function');
        require(Issuer().getDebt(stake, msg.sender) > 0, 'Synthx: Debt must be greater than zero');

        _stake(stake, amount, FROM_BALANCE);
        History().addAction('Stake', msg.sender, 'Stake', stake, amount, bytes32(0), 0);
        Liquidator().watchAccount(stake, msg.sender);
//        SynthxToken().mint();
        emit Staked(msg.sender, FROM_BALANCE, stake, amount);
        return true;
    }

    function _stake(
        bytes32 stake,
        uint256 amount,
        bytes32 from
    ) private onlyInitialized notPaused {
        require(amount > 0, 'Synthx: amount must be greater than zero');
        address stakeAddress = requireAsset('Stake', stake);

        if (from == FROM_TRANSFERABLE) {
            uint256 transferable = Staker().getTransferable(stake, msg.sender);
            transferable.sub(amount, 'Synthx: transfer amount exceeds transferable');
            return;
        }

        if (stake != nativeCoin) {
            IERC20 token = IERC20(stakeAddress);
            token.safeTransferFrom(
                msg.sender,
                address(this),
                amount.decimalsTo(PreciseMath.DECIMALS(), token.decimals())
            );
        }

        Staker().stake(stake, msg.sender, amount);
    }

    // 0xf82d43e5
    function mintFromCoin(uint256 mintedAmount) external payable returns (bool) {
        _mint(nativeCoin, msg.value, mintedAmount, FROM_BALANCE);
        return true;
    }

    function mintFromToken(bytes32 stake, uint256 amount, uint256 mintedAmount) external returns (bool) {
        require(stake != nativeCoin, 'Synthx: Native Coin use "mintFromCoin" function');

        _mint(stake, amount, mintedAmount, FROM_BALANCE);
        return true;
    }

    function mintFromTransferable(bytes32 stake, uint256 amount, uint256 mintedAmount) external returns (bool) {
        _mint(stake, amount, mintedAmount, FROM_TRANSFERABLE);
        return true;
    }

    function _mint(
        bytes32 stake,
        uint256 amount,
        uint256 mintedAmount,
        bytes32 from
    ) internal {
        _stake(stake, amount, from);
        uint256 value = amount.decimalMultiply(AssetPrice().getPrice(stake));
        uint256 collateralRate = Setting().getCollateralRate(stake);
        require(collateralRate > 0, 'Synthx: Missing Collateral Rate');

        uint256 issueAmount = value.decimalDivide(collateralRate);
        require(issueAmount >= mintedAmount, "Synthx: mint collateral rate too low");

        // dTokenMintedAmount
        uint256 totalDebt = Issuer().getTotalDebt();

        IERC20 token = IERC20(requireAddress(CONTRACT_SYNTHX_DTOKEN));
        uint256 dTokenTotalSupply = token.totalSupply();
        uint256 dTokenMintedAmount = 0;
        if (dTokenTotalSupply == 0 || totalDebt == 0) {
            dTokenMintedAmount = mintedAmount;
        } else {
            dTokenMintedAmount = dTokenTotalSupply.decimalMultiply(mintedAmount).decimalDivide(totalDebt);
        }
        // mint dToken
        SynthxDToken().mint(msg.sender, dTokenMintedAmount);

        // issue debt
        Issuer().issueDebt(stake, msg.sender, mintedAmount);

        History().addAction('Stake', msg.sender, 'Mint', stake, amount, USD, issueAmount);
        Liquidator().watchAccount(stake, msg.sender);
        SynthxToken().mint();
        emit Minted(msg.sender, from, stake, amount, issueAmount);
    }

    function burn(bytes32 stake, uint256 dTokenAmount) external onlyInitialized notPaused returns (bool) {
        uint256 totalDebt = Issuer().getTotalDebt();

        IERC20 token = IERC20(requireAddress(CONTRACT_SYNTHX_DTOKEN));
        uint256 dTokenTotalSupply = token.totalSupply();
        uint256 dUSDAmount = totalDebt.decimalMultiply(dTokenAmount).decimalDivide(dTokenTotalSupply);

        uint256 burnAmount = Issuer().burnDebt(stake, msg.sender, dUSDAmount, msg.sender);

        uint256 stakerTransferable = Staker().getTransferable(stake, msg.sender);
        if (Issuer().getDebt(stake, msg.sender) == 0) transfer(stake, msg.sender, stakerTransferable);

        // burn dToken
        SynthxDToken().burn(msg.sender, dTokenAmount);

        History().addAction('Stake', msg.sender, 'Burn', stake, 0, DTOKEN, dTokenAmount);
        Liquidator().watchAccount(stake, msg.sender);
        SynthxToken().mint();

        emit Burned(msg.sender, stake, burnAmount);
        return true;
    }

    function transfer(
        bytes32 stake,
        address payable recipient,
        uint256 amount
    ) public onlyInitialized notPaused returns (bool) {
        (uint256 transferable) = Staker().getTransferable(stake, msg.sender);
        transferable.sub(amount, 'Synthx: transfer amount exceeds transferable');

        Staker().unstake(stake, msg.sender, amount);

        if (stake == nativeCoin) {
            recipient.transfer(amount);
        } else {
            IERC20 token = IERC20(requireAsset('Stake', stake));
            token.safeTransfer(recipient, amount.decimalsTo(PreciseMath.DECIMALS(), token.decimals()));
        }

        History().addAction('Stake', msg.sender, 'Transfer', stake, amount, bytes32(0), 0);
        Liquidator().watchAccount(stake, msg.sender);
        SynthxToken().mint();
        emit Transfered(msg.sender, stake, recipient, amount);
        return true;
    }

    function trade(
        bytes32 fromSynth,
        uint256 fromAmount,
        bytes32 toSynth
    ) external onlyInitialized notPaused returns (bool) {
        (uint256 tradingAmount, uint256 tradingFee, uint256 fromSynthPrice, uint256 toSynthPirce) =
            Trader().trade(msg.sender, fromSynth, fromAmount, toSynth);

        Market().addTrade(fromSynth, fromAmount, fromSynthPrice, toSynth, tradingAmount, toSynthPirce);
        History().addTrade(msg.sender, fromSynth, fromAmount, fromSynthPrice, toSynth, tradingAmount, toSynthPirce);

        SynthxToken().mint();
        emit Traded(
            msg.sender,
            fromSynth,
            toSynth,
            fromAmount,
            tradingAmount,
            tradingFee,
            fromSynthPrice,
            toSynthPirce
        );
        return true;
    }

    function claimReward() external onlyInitialized notPaused returns (bool) {
        Rewards(CONTRACT_STAKER).claim(msg.sender);
        return true;
    }

    function liquidate(
        bytes32 stake,
        address account,
        uint256 amount
    ) external onlyInitialized notPaused returns (bool) {
        uint256 liquidable = Liquidator().getLiquidable(stake, account);
        liquidable.sub(amount, 'Synthx: liquidate amount exceeds liquidable');

        uint256 unstakable = Liquidator().getUnstakable(stake, amount);
        Issuer().burnDebt(stake, account, amount, msg.sender);
        Staker().unstake(stake, account, unstakable);

        if (stake == nativeCoin) {
            msg.sender.transfer(unstakable);
        } else {
            IERC20 token = IERC20(requireAsset('Stake', stake));
            token.safeTransfer(msg.sender, unstakable.decimalsTo(PreciseMath.DECIMALS(), token.decimals()));
        }

        SynthxToken().mint();
        emit Liquidated(msg.sender, stake, account, unstakable, amount);
        return true;
    }
}
