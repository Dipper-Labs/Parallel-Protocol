// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Ownable.sol';

contract Proxy is Ownable {
    bytes32 private constant TARGET_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event TargetChanged(address indexed previousTarget, address indexed newTarget);

    constructor(address target) public {
        setTarget(target);
    }

    modifier onlyTarget() {
        require(msg.sender == getTarget(), contractName.concat(': caller is not target'));
        _;
    }

    function setTarget(address target) public onlyOwner {
        require(target != address(0), contractName.concat('Proxy: new target is the zero address'));
        contractName = IOwnable(target).contractName().concat('Proxy');

        emit TargetChanged(getTarget(), target);
        bytes32 solt = TARGET_SLOT;
        assembly {
            sstore(solt, target)
        }
    }

    function implementation() external view returns (address) {
        return getTarget();
    }

    function getTarget() internal view returns (address) {
        bytes32 solt = TARGET_SLOT;
        address target;
        assembly {
            target := sload(solt)
        }
        return target;
    }

    function() external payable {
        _delegate(getTarget());
    }

    function _delegate(address target) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}
