// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

contract EncreptHelper {
    function encrept(string memory _str) internal pure returns (bytes32) {
        return keccak256(abi.encode(_str));
    }
}

contract CalculateHelper {
    function isSquare(uint256 amount) internal pure returns (bool) {
        uint256 sqrtAmount = sqrt(amount);
        return sqrtAmount * sqrtAmount == amount;
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}

contract Helper is 
    EncreptHelper,
    CalculateHelper 
    {}