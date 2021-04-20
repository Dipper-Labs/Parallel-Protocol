pragma solidity ^0.5.17;

import './Ownable.sol';

contract Proxyable is Ownable {
    bool private _initialized;

    modifier onlyInitialized() {
        require(_initialized, contractName.concat(': contract uninitialized'));
        _;
    }

    function setInitialized() internal {
        require(_initialized == false, contractName.concat(': already initialized'));
        _initialized = true;
    }
}
