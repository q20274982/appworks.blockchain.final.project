// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

struct ScordBoard {
    uint256 agreeScore;
    uint256 againstScore;
    
    // e.g. [address1, address2]
    address[] against;
    address[] agree;

    // e.g. { address1: 400 }
    mapping(address => uint256) againstIndex;
    mapping(address => uint256) agreeIndex;
}