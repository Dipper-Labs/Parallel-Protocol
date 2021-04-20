// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/TokenLockable.sol';
import './interfaces/ISynbitToken.sol';
import './interfaces/ISupplySchedule.sol';
import './interfaces/IIssuer.sol';
import './interfaces/IResolver.sol';

contract SynbitToken is TokenLockable, ISynbitToken {
    uint256 public constant CROWDSALE_SUPPLY = 1000E22;
    bytes32 private constant CROWDSALE_SUPPLY_DISTRIBUTED = 'CrowdsaleSupplyDistributed';

    IResolver public resolver;

    modifier onlyResolver() {
        require(msg.sender == address(resolver), 'SynbitToken: caller is not the Resolver');
        _;
    }

    function initialize(IResolver _resolver) external onlyOwner returns (bool) {
        setInitialized();
        resolver = _resolver;
        _name = 'Synbit Token';
        _symbol = 'SYN';
        setContractName(CONTRACT_SYNBIT_TOKEN);
        resetManager();
        return true;
    }

    function resetManager() public onlyOwner {
        setManager(resolver.getAddress(CONTRACT_ISSUER));
        setHolder(resolver.getAddress(CONTRACT_HOLDER));
    }

    function distributeCrowdsaleSupply() external onlyInitialized onlyOwner returns (bool) {
        require(
            Storage().getUint(CROWDSALE_SUPPLY_DISTRIBUTED, address(0)) == 0,
            'SynbitToken: Crowdsale Supply Distributed'
        );
        _mint(msg.sender, CROWDSALE_SUPPLY);
        Storage().setUint(CROWDSALE_SUPPLY_DISTRIBUTED, address(0), 1);
        emit CrowdsaleSupplyDistributed(msg.sender, CROWDSALE_SUPPLY);
        return true;
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
        _transfer(from, to, amount, 'SynbitToken: migrate amount exceeds balance');
        return true;
    }
}
