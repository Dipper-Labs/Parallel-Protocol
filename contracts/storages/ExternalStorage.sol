pragma solidity ^0.5.17;

import '../lib/SafeMath.sol';
import '../base/Storage.sol';

contract ExternalStorage is Storage {
    using SafeMath for uint256;

    bytes32 internal managerName = 'manager';

    constructor(address _manager) internal {
        setManager(_manager);
    }

    function setManager(address _manager) public onlyOwner {
        super.setManager(_manager);
        contractName = 'Storage';
        managerName = IOwnable(manager).contractName().toBytes32();
        if (managerName == '') managerName = 'manager';
    }
}
