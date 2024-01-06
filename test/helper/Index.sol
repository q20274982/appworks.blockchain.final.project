// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

abstract contract PermissionsTestHelper is Test {
    address private _credit;

    constructor(address credit_) {
        _credit = credit_;
    }
    
    function createReader() external returns (address addr) {
        addr = makeAddr("reader");
        deal(_credit, addr, 500e18);
    }

    function createMarker() external returns (address addr) {
        addr = makeAddr("marker");
        deal(_credit, addr, 500e18);
    }

    function createVoter() external returns (address addr) {
        addr = makeAddr("voter");
        deal(_credit, addr, 500e18);
    }
}

contract TestHelper is PermissionsTestHelper {
    constructor(address credit_) PermissionsTestHelper(credit_) {}
}