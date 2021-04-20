pragma solidity ^0.5.17;

import './Token.sol';
import '../interfaces/ILockable.sol';
import '../interfaces/IHolder.sol';

contract TokenLockable is Token, ILockable {
    bytes32 private constant LOCKED = 'Locked';
    IHolder public holder;

    modifier onlyHolder() {
        require(msg.sender == address(holder), contractName.concat(': caller is not the Holder'));
        _;
    }

    function setHolder(address _holder) public onlyOwner {
        require(_holder != address(0), contractName.concat(': new holder is the zero address'));
        emit HolderChanged(address(holder), _holder);
        holder = IHolder(_holder);
    }

    function lock(address account, uint256 amount) external onlyInitialized onlyHolder returns (bool) {
        _transfer(account, holder.LOCK_ADDRESS(), amount, ': lock amount exceeds balance');
        Storage().incrementUint(LOCKED, account, amount);
        return true;
    }

    function unlock(address account, uint256 amount) external onlyInitialized onlyHolder returns (bool) {
        Storage().decrementUint(LOCKED, account, amount, contractName.concat(': unlock amount exceeds locked'));
        _transfer(holder.LOCK_ADDRESS(), account, amount, ': unlock amount exceeds lockAddress balance');
        return true;
    }

    function getLocked(address account) external view onlyInitialized returns (uint256) {
        return Storage().getUint(LOCKED, account);
    }

    function getTotalLocked() external view onlyInitialized returns (uint256) {
        return balanceOf(holder.LOCK_ADDRESS());
    }
}
