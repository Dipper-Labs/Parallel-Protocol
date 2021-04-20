pragma solidity ^0.5.17;

import '../lib/SafeMath.sol';
import './Proxyable.sol';
import './ExternalStorable.sol';
import '../interfaces/storages/ITokenStorage.sol';
import '../interfaces/IERC20.sol';

contract Token is Proxyable, ExternalStorable, IERC20 {
    using SafeMath for uint256;

    bytes32 private constant TOTAL = 'Total';
    bytes32 private constant BALANCE = 'Balance';

    string internal _name;
    string internal _symbol;

    function Storage() internal view returns (ITokenStorage) {
        return ITokenStorage(getStorage());
    }

    function name() external view onlyInitialized returns (string memory) {
        return _name;
    }

    function symbol() external view onlyInitialized returns (string memory) {
        return _symbol;
    }

    function decimals() external view onlyInitialized returns (uint8) {
        return 18;
    }

    function totalSupply() external view onlyInitialized returns (uint256) {
        return Storage().getUint(TOTAL, address(0));
    }

    function balanceOf(address account) public view onlyInitialized returns (uint256) {
        return Storage().getUint(BALANCE, account);
    }

    function allowance(address owner, address spender) external view onlyInitialized returns (uint256) {
        return Storage().getAllowance(owner, spender);
    }

    function approve(address spender, uint256 amount) external onlyInitialized returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external onlyInitialized returns (bool) {
        _transfer(msg.sender, recipient, amount, ': transfer amount exceeds balance');
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external onlyInitialized returns (bool) {
        _transfer(sender, recipient, amount, ': transfer amount exceeds balance');
        uint256 delta =
            Storage().getAllowance(sender, msg.sender).sub(
                amount,
                contractName.concat(': transfer amount exceeds allowance')
            );
        _approve(sender, msg.sender, delta);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        Storage().setAllowance(owner, spender, amount);
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {
        Storage().decrementUint(BALANCE, sender, amount, contractName.concat(errorMessage));
        Storage().incrementUint(BALANCE, recipient, amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        Storage().incrementUint(BALANCE, account, amount);
        Storage().incrementUint(TOTAL, address(0), amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        Storage().decrementUint(BALANCE, account, amount, contractName.concat(': burn amount exceeds balance'));
        Storage().decrementUint(TOTAL, address(0), amount, contractName.concat(': burn amount exceeds totalSupply'));
        emit Transfer(account, address(0), amount);
    }
}
