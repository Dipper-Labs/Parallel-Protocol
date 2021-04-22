// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Token.sol';

import './interfaces/ISynthxDToken.sol';
import './interfaces/ISupplySchedule.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IResolver.sol';

contract SynthxDToken is Token, ISynthxDToken {
    IResolver public resolver;

    bytes32[] private MINTABLE_CONTRACTS = [CONTRACT_ISSUER, CONTRACT_SYNTHX];

    modifier onlyResolver() {
        require(msg.sender == address(resolver), 'SynthxDToken: caller is not the Resolver');
        _;
    }

    function initialize(IResolver _resolver) external onlyOwner returns (bool) {
        setInitialized();
        resolver = _resolver;
        _name = 'Synthx dToken';
        _symbol = 'dToken';
        setContractName(CONTRACT_SYNTHX_DTOKEN);
        resetManager();
        return true;
    }

    function resetManager() public onlyOwner {
        setManager(resolver.getAddress(CONTRACT_ISSUER));
    }

    function mint(address account, uint256 amount) external onlyInitialized returns (bool) {
        _mint(account, amount);
        return true;
    }

    function migrate(address from, address to) external onlyInitialized onlyResolver returns (bool) {
        uint256 amount = balanceOf(from);
        if (amount == 0) return true;
        _transfer(from, to, amount, 'SynthxDToken: migrate amount exceeds balance');
        return true;
    }
}
