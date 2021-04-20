// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Token.sol';
import './interfaces/ISynth.sol';

contract Synth is Token, ISynth {
    bytes32 private _category;

    function initialize(
        address issuer,
        string calldata name,
        string calldata symbol,
        bytes32 category
    ) external onlyOwner returns (bool) {
        setInitialized();
        setManager(issuer);
        _name = name;
        _symbol = symbol;
        _category = category;
        contractName = _symbol;
        return true;
    }

    function category() external view onlyInitialized returns (bytes32) {
        return _category;
    }

    function mint(address account, uint256 amount)
        external
        onlyInitialized
        onlyManager(CONTRACT_ISSUER)
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    function burn(address account, uint256 amount)
        external
        onlyInitialized
        onlyManager(CONTRACT_ISSUER)
        returns (bool)
    {
        _burn(account, amount);
        return true;
    }
}
