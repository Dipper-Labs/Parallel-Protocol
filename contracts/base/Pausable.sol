pragma solidity ^0.5.17;

import './Ownable.sol';

contract Pausable is Ownable {
    bool public paused;

    event PauseChanged(bool indexed previousValue, bool indexed newValue);

    modifier notPaused() {
        require(!paused, contractName.concat(': paused'));
        _;
    }

    constructor() internal {
        paused = false;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (paused == _paused) return;
        emit PauseChanged(paused, _paused);
        paused = _paused;
    }
}
