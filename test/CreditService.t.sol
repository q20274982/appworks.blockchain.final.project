// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TestHelper, PermissionsTestHelper} from "./helper/Index.sol";
import {CreditService, ErrorCodes, Permissions} from "../src/CreditService.sol";
import {Credit} from "../src/Credit.sol";

contract CreditServiceMarkTest is Test {
    string constant DUMMY_SCAM_STRING = "scam";

    CreditService creditService;
    Credit credit;

    TestHelper testHelper;
    address marker;

    function setUp() public {
        credit = new Credit(21_000_000e18);
        creditService = new CreditService(address(credit));

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
    }

    // 第一次 mark 时，返回 OK
    function test_when_first_time_mark_should_return_ok() public {
        vm.prank(marker);
        ErrorCodes result = creditService.mark(DUMMY_SCAM_STRING);

        assertEq(uint(result), uint(ErrorCodes.OK));
    }

    // 第二次 mark 时，返回 HAS_MARKED
    function test_when_second_time_mark_should_return_has_marked() public {
        vm.startPrank(marker);
        creditService.mark(DUMMY_SCAM_STRING);
        ErrorCodes result = creditService.mark(DUMMY_SCAM_STRING);
        vm.stopPrank();
        
        assertEq(uint(result), uint(ErrorCodes.HAS_MARKED));
    }
}