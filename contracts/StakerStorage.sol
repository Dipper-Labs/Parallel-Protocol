pragma solidity ^0.5.16;

contract StakerStorage is Owned {
    mapping(bytes32 => mapping(address => uint)) private _storage;

    constructor(address _owner) public Owned(_owner) {}

    function incrementStaked(
        bytes32 stake,
        address account,
        uint256 amount
    ) external onlyManager(managerName) returns (uint256) {
        _storage[stake][account] = _storage[stake][account].add(amount);
        _storage[stake][address(0)] = _storage[stake][address(0)].add(amount);
        return _storage[stake][account];
    }

    function decrementStaked(
        bytes32 stake,
        address account,
        uint256 amount,
        string calldata errorMessage
    ) external onlyManager(managerName) returns (uint256) {
        _storage[stake][account] = _storage[stake][account].sub(amount, errorMessage);
        _storage[stake][address(0)] = _storage[stake][address(0)].sub(amount, errorMessage);
        return _storage[stake][account];
    }

    function getStaked(bytes32 stake, address account) external view returns (uint256) {
        return _storage[stake][account];
    }
}