// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import "./helper/Index.sol";
import "../src/Credit.sol";
import "../src/struct/Mark.sol";
import "../src/Controller.sol";
import "../src/ControllerProxy.sol";

contract ClaimServiceTest is Test {
    string constant DUMMY_SCAM_STRING = "scam";
    string constant DUMMY_SCAM_STRING2 = "scam2";
    bytes32 constant DUMMY_SCAM_HASH = keccak256(abi.encode(DUMMY_SCAM_STRING));
    bytes32 constant DUMMY_SCAM_HASH2 = keccak256(abi.encode(DUMMY_SCAM_STRING2));
    uint256 constant MAXIMUM_SUPPLY = 21_000_000e18;

    ControllerV1 controller;
    ControllerProxy proxy;
    ControllerV1 controllerProxy;
    Credit credit;

    TestHelper testHelper;
    address owner;
    address marker;
    address[] agreeVoters;
    address[] againstVoters;

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
        _createVote();
    }

    function _createVote() private {
        // geenrate voter
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote1", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote2", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote3", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote4", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote5", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote6", 500e18));
        agreeVoters.push(testHelper.createRoleAndDeal("agreeVote7", 500e18));

        againstVoters.push(testHelper.createRoleAndDeal("againstVoter1", 500e18));
        againstVoters.push(testHelper.createRoleAndDeal("againstVoter2", 500e18));
        againstVoters.push(testHelper.createRoleAndDeal("againstVoter3", 500e18));
        againstVoters.push(testHelper.createRoleAndDeal("againstVoter4", 500e18));

        // mark
        vm.prank(marker);
        controllerProxy.mark(DUMMY_SCAM_STRING);

        // vote
        for (uint256 i = 0; i < agreeVoters.length; i++) {
            vm.startPrank(agreeVoters[i]);
            Credit(credit).approve(address(controllerProxy), 400e18);
            controllerProxy.vote(DUMMY_SCAM_STRING, true, 400e18);
            vm.stopPrank();
        }

        for (uint256 i = 0; i < againstVoters.length; i++) {
            vm.startPrank(againstVoters[i]);
            Credit(credit).approve(address(controllerProxy), 400e18);
            controllerProxy.vote(DUMMY_SCAM_STRING, false, 400e18);
            vm.stopPrank();
        }
    }

    function test_when_claim_unMarked_should_return_UN_MARKED() public {
        vm.prank(marker);
        ErrorCodes result = controllerProxy.claim(DUMMY_SCAM_HASH2);

        assertEq(uint(result), uint(ErrorCodes.UN_MARKED));
    }

    function test_when_claim_notMarker_should_return_NOT_MARKER() public {
        vm.prank(agreeVoters[0]);
        ErrorCodes result = controllerProxy.claim(DUMMY_SCAM_HASH);

        assertEq(uint(result), uint(ErrorCodes.NOT_MARKER));
    }

    function test_when_claim_notAbleToClaim_should_return_NOT_ABLE_TO_ClAIM() public {
        vm.prank(marker);
        ErrorCodes result = controllerProxy.claim(DUMMY_SCAM_HASH);

        assertEq(uint(result), uint(ErrorCodes.NOT_ABLE_TO_ClAIM));
    }

    function test_when_claim_should_return_OK() public {
        vm.prank(marker);
        vm.warp(block.timestamp + 7 days + 1);
        ErrorCodes result = controllerProxy.claim(DUMMY_SCAM_HASH);

        assertEq(uint(result), uint(ErrorCodes.OK));
    }

    function test_when_successful_claim_should_obtain_expected_result() public {
        vm.prank(marker);
        vm.warp(block.timestamp + 7 days + 1);
        controllerProxy.claim(DUMMY_SCAM_HASH);

        // reader get expected result
        address reader = testHelper.createReader();
        vm.prank(reader);
        bytes memory result = controllerProxy.readMark(DUMMY_SCAM_STRING);

        Mark memory mark = abi.decode(result, (Mark));
        
        assertEq(mark.markInfo.content, DUMMY_SCAM_STRING);
        assertEq(mark.markInfo.creator, marker);
        assertEq(mark.markInfo.createTime, block.timestamp - 7 days - 1);
        assertEq(mark.markResult.isScam, true);
        assertEq(mark.markResult.agreeVoter, 7);
        assertEq(mark.markResult.againstVoter, 4);
        assertEq(mark.markResult.ratio, 63);
        
        // voter get expected reward & deposit
        assertEq(Credit(credit).balanceOf(agreeVoters[0]), 500e18 + 50e18);

        // TODO:
        // claimer should be marker
        // claimer should get expected reward
        // lost voter's deposit should burned
    }
}
