// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./enum/ErrorCodes.sol";
import "./CommomStorage.sol";
import "./Credit.sol";

interface IClaimSerivce {
    function claim(bytes32 scamHash) external returns(ErrorCodes);
}

contract ClaimService is IClaimSerivce, CommomStorage {

    uint256 public constant DURATION = 7 days;
    uint256 public constant RewardAmount = 50e18;

    function claim(bytes32 scamHash) public returns (ErrorCodes) {
        if (!hasMarkedMap[scamHash]) return ErrorCodes.UN_MARKED; 
        MarkInfo memory markInfo = marksInfoMap[scamHash];
        if (markInfo.creator != msg.sender) return ErrorCodes.NOT_MARKER;
        if (block.timestamp <= markInfo.createTime + DURATION) return ErrorCodes.NOT_ABLE_TO_ClAIM;

        _processingReward(scamHash);

        return ErrorCodes.OK;
    }

    function _processingReward(bytes32 scamHash) private {
        ScoreBoard storage scoreBoard = scoreBoardMap[scamHash];

        bool isAgreeWin = scoreBoard.agreeScore >= scoreBoard.againstScore;
        address[] memory list = isAgreeWin ? scoreBoard.agree : scoreBoard.against;
        mapping(address => uint256) storage index = isAgreeWin ? scoreBoard.agreeIndex : scoreBoard.againstIndex;

        hasMarkedResultMap[scamHash] = true;
        marksResultMap[scamHash] = MarkResult({
            isScam: isAgreeWin,
            agreeVoter: scoreBoard.agree.length,
            againstVoter: scoreBoard.against.length,
            ratio: scoreBoard.agreeScore * 100 / (scoreBoard.agreeScore + scoreBoard.againstScore)
        });

        for(uint256 i = 0; i < list.length; i++) {
            address winner = list[i];
            uint256 voterDepositAmount = index[list[i]];
            uint256 systeamRewardAmount = _getSysteamReward();

            Credit(tokenAddr).mint(winner, systeamRewardAmount);
            IERC20(tokenAddr).transfer(winner, voterDepositAmount);
        }
    }

    function _getSysteamReward() private pure returns(uint256) {
        // TODO: replace with dynamic reward
        return RewardAmount;
    }
}

