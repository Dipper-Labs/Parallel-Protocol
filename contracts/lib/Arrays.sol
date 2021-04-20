pragma solidity ^0.5.17;

library Arrays {
    function push(bytes32[] storage array, bytes32 element) internal {
        (bool exist, ) = index(array, element);
        if (exist) return;
        array.push(element);
    }

    function remove(bytes32[] storage array, bytes32 element) internal {
        (bool exist, uint256 i) = index(array, element);
        if (!exist) return;
        uint256 last = array.length - 1;
        array[i] = array[last];
        array.length = last;
    }

    function index(bytes32[] storage array, bytes32 element) internal view returns (bool, uint256) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) return (true, i);
        }
        return (false, 0);
    }
}
