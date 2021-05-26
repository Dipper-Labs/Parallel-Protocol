// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/Token.sol';
import './base/Importable.sol';

import './interfaces/ISynthxDToken.sol';
import './interfaces/ISupplySchedule.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IResolver.sol';

contract SynthxDToken is Token, Importable, ISynthxDToken {
    bytes32[] private MINTABLE_CONTRACTS = [CONTRACT_ISSUER, CONTRACT_SYNTHX];

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_SYNTHX_DTOKEN);
        imports = [CONTRACT_ISSUER, CONTRACT_SYNTHX];
    }

    modifier onlyResolver() {
        require(msg.sender == address(resolver), 'SynthxDToken: caller is not the Resolver');
        _;
    }

    function initialize() external onlyOwner returns (bool) {
        setInitialized();
        _name = 'Synthx dToken';
        _symbol = 'dToken';
        setContractName(CONTRACT_SYNTHX_DTOKEN);
        resetManager();
        return true;
    }

    function resetManager() public onlyOwner {
        setManager(resolver.getAddress(CONTRACT_ISSUER));
    }

    function mint(address account, uint256 amount) external onlyInitialized containAddress(MINTABLE_CONTRACTS) returns (bool) {
        _mint(account, amount);
        return true;
    }

    function burn(address account, uint256 amount) external onlyInitialized containAddress(MINTABLE_CONTRACTS) returns (bool){
        _burn(account, amount);
        return true;
    }

    function migrate(address from, address to) external onlyInitialized onlyResolver returns (bool) {
        uint256 amount = balanceOf(from);
        if (amount == 0) return true;
        _transfer(from, to, amount, 'SynthxDToken: migrate amount exceeds balance');
        return true;
    }
}
