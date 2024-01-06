// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "./helper/Index.sol";

import "../src/Controller.sol";
import "../src/ControllerProxy.sol";
import "../src/Credit.sol";

contract ControllerTest is Test {

    uint256 constant MAXIMUM_SUPPLY = 21_000_000e18;
    TestHelper testHelper;

    ControllerV1 controller;
    ControllerProxy proxy;
    ControllerV1 controllerProxy;
    Credit credit;

    address owner;
    address marker;
    address reader;

    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);
        credit = new Credit(MAXIMUM_SUPPLY);
        controller = new ControllerV1();
        proxy = new ControllerProxy(address(controller));
        controllerProxy = ControllerV1(address(proxy));
        ControllerInitializeParams memory initParams = ControllerInitializeParams({
            tokenAddr: address(credit),
            reader: 500e18,
            marker: 500e18,
            voter: 500e18
        });
        
        controllerProxy.initialize(initParams);
        vm.stopPrank();

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
        reader = testHelper.createReader();
    }

    function test_after_initialize_call_VERSION_should_return_001() public {
        assertEq(controllerProxy.VERSION(), "0.0.1");
    }

    function test_createMark_should_return_ErrorCodes_OK() public {
        vm.prank(marker);
        ErrorCodes code = controllerProxy.createMark("test");

        assertEq(uint(code), uint(ErrorCodes.OK));
    }

    function test_readMark_should_return_markInfo() public {
        vm.prank(marker);
        controllerProxy.createMark("test");

        vm.prank(reader);
        bytes memory result = controllerProxy.readMark("test");
        assert(result.length > 0);
    }
}