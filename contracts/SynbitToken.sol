// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/TokenLockable.sol';
import './interfaces/ISynthxToken.sol';
import './interfaces/ISupplySchedule.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IResolver.sol';

contract SynthxToken is TokenLockable, ISynthxToken {
    uint256 public constant CROWDSALE_SUPPLY = 1000E22;

    IResolver public resolver;

    modifier onlyResolver() {
        require(msg.sender == address(resolver), 'SynthxToken: caller is not the Resolver');
        _;
    }

    function initialize(IResolver _resolver) external onlyOwner returns (bool) {
        setInitialized();
        resolver = _resolver;
        _name = 'Synthx Token';
        _symbol = 'SYNX';
        setContractName(CONTRACT_SYNTHX_TOKEN);
        resetManager();
        return true;
    }

    function resetManager() public onlyOwner {
        setManager(resolver.getAddress(CONTRACT_ISSUER));
        setHolder(resolver.getAddress(CONTRACT_HOLDER));
    }

    function mint() external onlyInitialized returns (bool) {
        address supplySchedule = resolver.getAddress(CONTRACT_SUPPLY_SCHEDULE);
        if (supplySchedule == address(0)) return false;
        (address[] memory recipients, uint256[] memory amounts) = ISupplySchedule(supplySchedule).distributeSupply();
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = amounts[i];
            if (amount > 0) _mint(recipients[i], amount);
        }
        return true;
    }

    function migrate(address from, address to) external onlyInitialized onlyResolver returns (bool) {
        uint256 amount = balanceOf(from);
        if (amount == 0) return true;
        _transfer(from, to, amount, 'SynthxToken: migrate amount exceeds balance');
        return true;
    }
}
