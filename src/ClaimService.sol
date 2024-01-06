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
        ScordBoard storage scordBoard = scordBoardMap[scamHash];

        bool isAgreeWin = scordBoard.agreeScore >= scordBoard.againstScore;
        address[] memory list = isAgreeWin ? scordBoard.agree : scordBoard.against;
        mapping(address => uint256) storage index = isAgreeWin ? scordBoard.agreeIndex : scordBoard.againstIndex;

        hasMarkedResultMap[scamHash] = true;
        marksResultMap[scamHash] = MarkResult({
            isScam: isAgreeWin,
            totalVoter: list.length,
            ratio: scordBoard.agreeScore * 100 / (scordBoard.agreeScore + scordBoard.againstScore)
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
