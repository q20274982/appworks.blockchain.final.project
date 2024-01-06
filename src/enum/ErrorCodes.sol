// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

enum ErrorCodes {
    OK, // OK
    HAS_MARKED, // 已經標記過
    INVALID, // 無效的
    UN_MARKED, // 未標記過
    INVALID_AMOUNT, // 無效的金額
    MARKER_NOT_ALLOW_TO_CLAIM,
    NOT_ABLE_TO_ClAIM,
    UNAUTHORIZED,
    UNEXPECTED
}