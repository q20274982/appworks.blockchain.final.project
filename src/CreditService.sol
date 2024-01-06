// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./enum/ErrorCodes.sol";
import "./CommomStorage.sol";
import "./Permissions.sol";
import "./struct/Mark.sol";
import "./struct/Score.sol";
import "./helper/Helper.sol";

interface ICreditService {
    function mark(string calldata scam) external returns (ErrorCodes);
    function vote(string calldata scam, bool isAgree, uint256 amount) external returns (ErrorCodes);
    function readMarkInfo(string calldata scam) view external returns (bytes memory);
    function readMarkInfos(string[] calldata scams) view external returns (bytes[] memory);
    function readMarkResult(string calldata scam) view external returns (bytes memory);
    function readMarkResults(string[] calldata scams) view external returns (bytes[] memory);
}

contract CreditService is ICreditService, CommomStorage, Helper {

    function crditServiceInitialize(address tokenAddr_) public {
        tokenAddr = tokenAddr_;
    }

    function mark(string calldata scam) public returns (ErrorCodes) {
        bytes32 scamHash = encrept(scam);

        if (hasMarkedMap[scamHash]) return ErrorCodes.HAS_MARKED;

        _mark(scam);
        return ErrorCodes.OK;
    }

    function _mark(string calldata scam) internal {
        bytes32 scamHash = encrept(scam);
        hasMarkedMap[scamHash] = true;
        marksInfoMap[scamHash] = MarkInfo({
            content: scam,
            creator: msg.sender,
            createTime: block.timestamp
        });
    }

    function vote(string calldata scam, bool isAgree, uint256 amount) public returns (ErrorCodes) {
        bytes32 scamHash = encrept(scam);

        if (!hasMarkedMap[scamHash]) return ErrorCodes.UN_MARKED; 

        _vote(
            scamHash,
            _calculateMaxVoteAmount(amount),
            isAgree,
            msg.sender
        );
        return ErrorCodes.OK;
    }

    function _calculateMaxVoteAmount(uint256 amount) internal pure returns (uint256) {
        return sqrt(amount) ** 2;
    }

    function _vote(bytes32 scamHash, uint256 amount, bool position, address voter) internal {
        // 1. 紀錄 voter 的投票選項, 金額, 哪一筆 mark
        if (position) {
            scoreBoardMap[scamHash].agree.push(voter);
            scoreBoardMap[scamHash].agreeIndex[voter] = amount;
            scoreBoardMap[scamHash].agreeScore = _calculateScore(scoreBoardMap[scamHash].agreeScore, amount);

        } else {
            scoreBoardMap[scamHash].against.push(voter);
            scoreBoardMap[scamHash].againstIndex[voter] = amount;
            scoreBoardMap[scamHash].againstScore = _calculateScore(scoreBoardMap[scamHash].againstScore, amount);

        }

        // 2. transfer 對應 amount 的金額到 contract
        IERC20(tokenAddr).transferFrom(voter, address(this), amount);
    }

    function _calculateScore(uint256 currentScore, uint256 voteAmount) private pure returns(uint256) {
        return sqrt(voteAmount) ** 2 + currentScore;
    }

    function readMarkInfo(string calldata scam) view public returns (bytes memory) {
        bytes32 scamHash = encrept(scam);
        return abi.encode(marksInfoMap[scamHash]);
    }

    function readMarkInfos(string[] calldata scams) view public returns (bytes[] memory) {
        bytes[] memory marks = new bytes[](scams.length);

        for (uint i = 0; i < scams.length; i++) {
            bytes32 scamHash = encrept(scams[i]);
            marks[i] = abi.encode(marksInfoMap[scamHash]);
        }

        return marks;
    }

    function readMarkResult(string calldata scam) view public returns (bytes memory) {
        bytes32 scamHash = encrept(scam);
        return abi.encode(marksResultMap[scamHash]);
    }

    function readMarkResults(string[] calldata scams) view public returns (bytes[] memory) {
        bytes[] memory marks = new bytes[](scams.length);

        for (uint i = 0; i < scams.length; i++) {
            bytes32 scamHash = encrept(scams[i]);
            marks[i] = abi.encode(marksResultMap[scamHash]);
        }

        return marks;
    }

}
