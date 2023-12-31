// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface ICreditService {}

enum ErrorCodes {
    OK,
    HAS_MARKED,
    INVALID,
    NOT_FOUND,
    UNAUTHORIZED,
    UNEXPECTED
}

struct Record {

    address creator;
    uint256 crateTime;
}


abstract contract Permissions {
    uint256 private _reader;
    uint256 private _marker;
    uint256 private _voter;

    address private _credit;
    
    error NotEnoughBalanceOfReader();
    error NotEnoughBalanceOfMarker();
    error NotEnoughBalanceOfVoter();
    
    constructor(address credit_, uint256 reader_, uint256 marker_, uint256 voter_) {
        _credit = credit_;
        _reader = reader_;
        _marker = marker_;
        _voter = voter_;
    }

    modifier onlyReader {
        if (IERC20(_credit).balanceOf(msg.sender) < _reader) {
            revert NotEnoughBalanceOfReader();
        }
        
        _;
    }
    
    modifier onlyMarker {
        if (IERC20(_credit).balanceOf(msg.sender) < _marker) {
            revert NotEnoughBalanceOfMarker();
        }
        
        _;
    }
    
    modifier onlyVoter {
        if (IERC20(_credit).balanceOf(msg.sender) < _voter) {
            revert NotEnoughBalanceOfVoter();
        }

        _;
    }

}

contract CreditService is ICreditService, Permissions {

    constructor(address tokenAddr_) Permissions(tokenAddr_, 500e18, 500e18, 500e18) {}

    mapping(string => bool) public records;
    
    function mark(string calldata scam) external onlyMarker returns (ErrorCodes) {
        if (records[scam]) {
            return ErrorCodes.HAS_MARKED;
        }

        _mark(scam);
        return ErrorCodes.OK;
    }

    function _mark(string calldata scam) internal {
        records[scam] = true;
    }

    function vote() external returns (uint8) {}

    function reads(string[] calldata scams) external {}

    function claim() external {}
}
