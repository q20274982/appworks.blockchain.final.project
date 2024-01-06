// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import "./helper/Index.sol";
import "../src/CreditService.sol";
import "../src/Credit.sol";
import "../src/struct/Mark.sol";


contract CreditServiceMarkTest is Test {
    string constant DUMMY_SCAM_STRING = "scam";

    CreditService creditService;
    Credit credit;

    TestHelper testHelper;
    address marker;
    address reader;

    function setUp() public {
        credit = new Credit(21_000_000e18);
        creditService = new CreditService();
        creditService.crditServiceInitialize(address(credit));

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
        reader = testHelper.createReader();
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

    // mark 时，应该设置正确的 markInfo
    function test_when_first_time_mark_should_set_correct_mark() public {
        vm.prank(marker);
        creditService.mark(DUMMY_SCAM_STRING);

        vm.prank(reader);
        bytes memory encodedResult = creditService.readMarkInfo(DUMMY_SCAM_STRING);
        MarkInfo memory result = abi.decode(encodedResult, (MarkInfo));

        assertEq(result.content, DUMMY_SCAM_STRING);
        assertEq(result.creator, marker);
        assertEq(result.createTime, block.timestamp);
    }
}

contract CreditServiceReadTest is Test {
    string constant DUMMY_SCAM_STRING = "scam";

    CreditService creditService;
    Credit credit;

    TestHelper testHelper;
    address marker;
    address reader;

    function setUp() public {
        credit = new Credit(21_000_000e18);
        creditService = new CreditService();
        creditService.crditServiceInitialize(address(credit));

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
        reader = testHelper.createReader();
    }

    function test_read_when_not_marked_should_return_empty() public {
        vm.prank(reader);
        bytes memory encodedResult = creditService.readMarkInfo(DUMMY_SCAM_STRING);
        assertEq(encodedResult, abi.encode(MarkInfo("", address(0), 0)));
    }

    function test_read_when_marked_should_return_marked_info() public {
        vm.startPrank(marker);
        creditService.mark(DUMMY_SCAM_STRING);
        vm.stopPrank();

        vm.prank(reader);
        bytes memory encodedResult = creditService.readMarkInfo(DUMMY_SCAM_STRING);

        MarkInfo memory result1 = abi.decode(encodedResult, (MarkInfo));
        assertEq(result1.content, DUMMY_SCAM_STRING);
        assertEq(result1.creator, marker);
        assertEq(result1.createTime, block.timestamp);
    }
}

contract CreditServiceReadsTest is Test {
    string constant DUMMY_SCAM_STRING_1 = "scam1";
    string constant DUMMY_SCAM_STRING_2 = "scam2";

    CreditService creditService;
    Credit credit;

    TestHelper testHelper;
    address marker;
    address reader;

    function setUp() public {
        credit = new Credit(21_000_000e18);
        creditService = new CreditService();
        creditService.crditServiceInitialize(address(credit));

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
        reader = testHelper.createReader();
    }

    function test_when_not_marked_should_return_empty() public {
        string[] memory scams = new string[](2);
        scams[0] = DUMMY_SCAM_STRING_1;
        scams[1] = DUMMY_SCAM_STRING_2;

        vm.prank(reader);
        bytes[] memory encodedResults = creditService.readMarkInfos(scams);

        bytes memory encodedResult1 = encodedResults[0];
        bytes memory encodedResult2 = encodedResults[1];

        assertEq(encodedResults.length, 2);
        assertEq(encodedResult1, abi.encode(MarkInfo("", address(0), 0)));
        assertEq(encodedResult2, abi.encode(MarkInfo("", address(0), 0)));
    }

    function test_when_marked_should_return_marked_info() public {
        vm.startPrank(marker);
        creditService.mark(DUMMY_SCAM_STRING_1);
        creditService.mark(DUMMY_SCAM_STRING_2);
        vm.stopPrank();

        string[] memory scams = new string[](2);
        scams[0] = DUMMY_SCAM_STRING_1;
        scams[1] = DUMMY_SCAM_STRING_2;

        vm.prank(reader);
        bytes[] memory encodedResults = creditService.readMarkInfos(scams);

        MarkInfo memory result1 = abi.decode(encodedResults[0], (MarkInfo));
        assertEq(result1.content, DUMMY_SCAM_STRING_1);
        assertEq(result1.creator, marker);
        assertEq(result1.createTime, block.timestamp);

        MarkInfo memory result2 = abi.decode(encodedResults[1], (MarkInfo));
        assertEq(result2.content, DUMMY_SCAM_STRING_2);
        assertEq(result2.creator, marker);
        assertEq(result2.createTime, block.timestamp);
    }
}

contract CreditServiceVoteTest is Test {
    string constant DUMMY_SCAM_STRING = "scam";
    uint256 constant DUMMY_VOTE_AMOUNT = 100e18;

    CreditService creditService;
    Credit credit;

    TestHelper testHelper;
    address marker;
    address reader;
    address voter;

    function setUp() public {
        credit = new Credit(21_000_000e18);
        creditService = new CreditService();
        creditService.crditServiceInitialize(address(credit));

        testHelper = new TestHelper(address(credit));
        marker = testHelper.createMarker();
        reader = testHelper.createReader();
        voter = testHelper.createVoter();
    }

    function test_when_vote_marked_should_return_ok_errorCodes() public {
        vm.prank(marker);
        creditService.mark(DUMMY_SCAM_STRING);
        
        vm.startPrank(voter);
        IERC20(credit).approve(address(creditService), DUMMY_VOTE_AMOUNT);
        ErrorCodes result = creditService.vote(DUMMY_SCAM_STRING, true, DUMMY_VOTE_AMOUNT);
        vm.stopPrank();

        assertEq(uint(result), uint(ErrorCodes.OK));
    }

    function test_when_vote_unmarked_should_return_unmarked_errorCodes() public {
        vm.startPrank(voter);
        IERC20(credit).approve(address(creditService), DUMMY_VOTE_AMOUNT);
        ErrorCodes result = creditService.vote(DUMMY_SCAM_STRING, true, DUMMY_VOTE_AMOUNT);
        vm.stopPrank();

        assertEq(uint(result), uint(ErrorCodes.UN_MARKED));
    }
}