// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './lib/SafeMath.sol';
import './lib/PreciseMath.sol';
import './lib/SafeERC20.sol';
import './base/Proxyable.sol';
import './base/Pausable.sol';
import './base/Importable.sol';
import './interfaces/ISynbit.sol';
import './interfaces/IEscrow.sol';
import './interfaces/IStaker.sol';
import './interfaces/ITrader.sol';
import './interfaces/IAssetPrice.sol';
import './interfaces/ISetting.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IHolder.sol';
import './interfaces/IProvider.sol';
import './interfaces/IRewards.sol';
import './interfaces/ISynbitToken.sol';
import './interfaces/IMarket.sol';
import './interfaces/IHistory.sol';
import './interfaces/ILiquidator.sol';
import './interfaces/IERC20.sol';

contract Synbit is Proxyable, Pausable, Importable, ISynbit {
    using SafeMath for uint256;
    using PreciseMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 private constant FROM_BALANCE = 'FromBalance';
    bytes32 private constant FROM_ESCROW = 'FromEscrow';
    bytes32 private constant FROM_TRANSFERABLE = 'FromTransferable';

    bytes32 public nativeCoin;

    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver, bytes32 _nativeCoin) external onlyOwner returns (bool) {
        setInitialized();
        resolver = _resolver;
        nativeCoin = _nativeCoin;
        setContractName(CONTRACT_SYNBIT);
        imports = [
            CONTRACT_ESCROW,
            CONTRACT_STAKER,
            CONTRACT_ASSET_PRICE,
            CONTRACT_SETTING,
            CONTRACT_ISSUER,
            CONTRACT_TRADER,
            CONTRACT_HOLDER,
            CONTRACT_SYNBIT_TOKEN,
            CONTRACT_PROVIDER,
            CONTRACT_MARKET,
            CONTRACT_HISTORY,
            CONTRACT_LIQUIDATOR,
            CONTRACT_SPECIAL
        ];
        return true;
    }

    function Escrow() private view returns (IEscrow) {
        return IEscrow(requireAddress(CONTRACT_ESCROW));
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

    function Holder() private view returns (IHolder) {
        return IHolder(requireAddress(CONTRACT_HOLDER));
    }

    function Provider() private view returns (IProvider) {
        return IProvider(requireAddress(CONTRACT_PROVIDER));
    }

    function Rewards(bytes32 reward) private view returns (IRewards) {
        return IRewards(requireAddress(reward));
    }

    function SynbitToken() private view returns (ISynbitToken) {
        return ISynbitToken(requireAddress(CONTRACT_SYNBIT_TOKEN));
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
        require(Issuer().getDebt(nativeCoin, msg.sender) > 0, 'Synbit: Debt must be greater than zero');

        _stake(nativeCoin, msg.value, FROM_BALANCE);
        History().addAction('Stake', msg.sender, 'Stake', nativeCoin, msg.value, bytes32(0), 0);
        Liquidator().watchAccount(nativeCoin, msg.sender);
        SynbitToken().mint();
        emit Staked(msg.sender, FROM_BALANCE, nativeCoin, msg.value);
        return true;
    }

    function stakeFromEscrow(uint256 amount) external returns (bool) {
        require(Issuer().getDebt(SYN, msg.sender) > 0, 'Synbit: Debt must be greater than zero');

        _stake(SYN, amount, FROM_ESCROW);
        History().addAction('Stake', msg.sender, 'Stake', SYN, amount, bytes32(0), 0);
        Liquidator().watchAccount(SYN, msg.sender);
        SynbitToken().mint();
        emit Staked(msg.sender, FROM_ESCROW, SYN, amount);
        return true;
    }

    function stakeFromToken(bytes32 stake, uint256 amount) external returns (bool) {
        require(stake != nativeCoin, 'Synbit: Native Coin use "mintFromCoin" function');
        require(Issuer().getDebt(stake, msg.sender) > 0, 'Synbit: Debt must be greater than zero');

        _stake(stake, amount, FROM_BALANCE);
        History().addAction('Stake', msg.sender, 'Stake', stake, amount, bytes32(0), 0);
        Liquidator().watchAccount(stake, msg.sender);
        SynbitToken().mint();
        emit Staked(msg.sender, FROM_BALANCE, stake, amount);
        return true;
    }

    function _stake(
        bytes32 stake,
        uint256 amount,
        bytes32 from
    ) private onlyInitialized notPaused {
        require(amount > 0, 'Synbit: amount must be greater than zero');
        address stakeAddress = requireAsset('Stake', stake);

        if (from == FROM_TRANSFERABLE) {
            (uint256 transferable, ) = Staker().getTransferable(stake, msg.sender);
            transferable.sub(amount, 'Synbit: transfer amount exceeds transferable');
            return;
        }

        if (stake == SYN && from == FROM_ESCROW) {
            Escrow().stake(msg.sender, amount);
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

    function mintFromCoin() external payable returns (bool) {
        _mint(nativeCoin, msg.value, FROM_BALANCE);
        return true;
    }

    function mintFromEscrow(uint256 amount) external returns (bool) {
        _mint(SYN, amount, FROM_ESCROW);
        return true;
    }

    function mintFromToken(bytes32 stake, uint256 amount) external returns (bool) {
        require(stake != nativeCoin, 'Synbit: Native Coin use "mintFromCoin" function');

        _mint(stake, amount, FROM_BALANCE);
        return true;
    }

    function mintFromTransferable(bytes32 stake, uint256 amount) external returns (bool) {
        _mint(stake, amount, FROM_TRANSFERABLE);
        return true;
    }

    function _mint(
        bytes32 stake,
        uint256 amount,
        bytes32 from
    ) internal {
        _stake(stake, amount, from);
        uint256 value = amount.decimalMultiply(AssetPrice().getPrice(stake));
        uint256 collateralRate = Setting().getCollateralRate(stake);
        require(collateralRate > 0, 'Synbit: Missing Collateral Rate');

        uint256 issueAmount = value.decimalDivide(collateralRate);
        Issuer().issueDebt(stake, msg.sender, issueAmount);

        History().addAction('Stake', msg.sender, 'Mint', stake, amount, USD, issueAmount);
        Liquidator().watchAccount(stake, msg.sender);
        SynbitToken().mint();
        emit Minted(msg.sender, from, stake, amount, issueAmount);
    }

    function burn(bytes32 stake, uint256 amount) external onlyInitialized notPaused returns (bool) {
        uint256 burnAmount = Issuer().burnDebt(stake, msg.sender, amount, msg.sender);

        (uint256 stakerTransferable, uint256 escrowTransferable) = Staker().getTransferable(stake, msg.sender);
        if (escrowTransferable > 0) Escrow().unstake(msg.sender, escrowTransferable);
        if (Issuer().getDebt(stake, msg.sender) == 0) transfer(stake, msg.sender, stakerTransferable);

        History().addAction('Stake', msg.sender, 'Burn', stake, 0, USD, amount);
        Liquidator().watchAccount(stake, msg.sender);
        SynbitToken().mint();
        emit Burned(msg.sender, stake, burnAmount);
        return true;
    }

    function transfer(
        bytes32 stake,
        address payable recipient,
        uint256 amount
    ) public onlyInitialized notPaused returns (bool) {
        (uint256 transferable, ) = Staker().getTransferable(stake, msg.sender);
        transferable.sub(amount, 'Synbit: transfer amount exceeds transferable');

        Staker().unstake(stake, msg.sender, amount);

        if (stake == nativeCoin) {
            recipient.transfer(amount);
        } else {
            IERC20 token = IERC20(requireAsset('Stake', stake));
            token.safeTransfer(recipient, amount.decimalsTo(PreciseMath.DECIMALS(), token.decimals()));
        }

        History().addAction('Stake', msg.sender, 'Transfer', stake, amount, bytes32(0), 0);
        Liquidator().watchAccount(stake, msg.sender);
        SynbitToken().mint();
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

        SynbitToken().mint();
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

    function lock(
        bytes32 asset,
        uint256 amount,
        bool isPool
    ) external onlyInitialized notPaused returns (bool) {
        if (isPool) {
            IERC20 token = IERC20(requireAsset('Pool', asset));
            token.safeTransferFrom(
                msg.sender,
                address(this),
                amount.decimalsTo(PreciseMath.DECIMALS(), token.decimals())
            );
            Provider().lock(asset, msg.sender, amount);
        } else {
            Holder().lock(asset, msg.sender, amount);
        }

        SynbitToken().mint();
        emit Locked(msg.sender, asset, amount, isPool);
        return true;
    }

    function unlock(
        bytes32 asset,
        uint256 amount,
        bool isPool
    ) external onlyInitialized notPaused returns (bool) {
        if (isPool) {
            Provider().unlock(asset, msg.sender, amount);
            IERC20 token = IERC20(requireAsset('Pool', asset));
            token.safeTransfer(msg.sender, amount.decimalsTo(PreciseMath.DECIMALS(), token.decimals()));
        } else {
            Holder().unlock(asset, msg.sender, amount);
        }

        SynbitToken().mint();
        emit Unlocked(msg.sender, asset, amount, isPool);
        return true;
    }

    function claim(bytes32 reward, bytes32 asset) external onlyInitialized notPaused returns (bool) {
        (uint256 period, uint256 amount, uint256 vestTime) = Rewards(reward).claim(asset, msg.sender);
        History().addAction('Claim', msg.sender, reward, asset, vestTime, (asset == USD) ? USD : SYN, amount);
        SynbitToken().mint();
        emit Claimed(msg.sender, reward, asset, period, amount, vestTime);
        return true;
    }

    function vest(uint256 amount) external onlyInitialized notPaused returns (bool) {
        Escrow().withdraw(msg.sender, amount);
        History().addAction('Vest', msg.sender, 'Escrow', SYN, amount, bytes32(0), 0);
        SynbitToken().mint();
        emit Vested(msg.sender, amount);
        return true;
    }

    function liquidate(
        bytes32 stake,
        address account,
        uint256 amount
    ) external onlyInitialized notPaused returns (bool) {
        uint256 liquidable = Liquidator().getLiquidable(stake, account);
        liquidable.sub(amount, 'Synbit: liquidate amount exceeds liquidable');

        uint256 unstakable = Liquidator().getUnstakable(stake, amount);
        Issuer().burnDebt(stake, account, amount, msg.sender);
        Staker().unstake(stake, account, unstakable);

        if (stake == nativeCoin) {
            msg.sender.transfer(unstakable);
        } else {
            IERC20 token = IERC20(requireAsset('Stake', stake));
            token.safeTransfer(msg.sender, unstakable.decimalsTo(PreciseMath.DECIMALS(), token.decimals()));
        }

        SynbitToken().mint();
        emit Liquidated(msg.sender, stake, account, unstakable, amount);
        return true;
    }
}
