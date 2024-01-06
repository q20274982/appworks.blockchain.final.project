// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

struct MarkInfo {
    // marked content
    string content;

    // mark creator
    address creator;

    // mark createTime
    uint256 createTime;
}

struct MarkResult {
    bool isScam;

    uint256 agreeVoter;

    uint256 againstVoter;

    uint256 ratio;
}

struct Mark {
    MarkInfo markInfo;
    MarkResult markResult;
}