// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "./struct/Mark.sol";
import "./struct/Scord.sol";

abstract contract CommomStorage {
    // 紀錄 ERC-20 token 地址
    address internal tokenAddr;
    
    // 紀錄是否已經被標記
    mapping(bytes32 => bool) internal hasMarkedMap;
    
    // 紀錄 mark 基本資訊
    mapping(bytes32 => MarkInfo) internal marksInfoMap;

    // 紀錄 mark 投票計分板
    mapping(bytes32 => ScordBoard) internal scordBoardMap;

    // 紀錄 mark 是否結果
    mapping(bytes32 => bool) internal hasMarkedResultMap;
    
    // 紀錄 mark 結果資訊
    mapping(bytes32 => MarkResult) internal marksResultMap;
    
}