// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct PermissionsParams {
    address credit;
    uint256 reader;
    uint256 marker;
    uint256 voter;
}

abstract contract Permissions {
    uint256 private _reader;
    uint256 private _marker;
    uint256 private _voter;

    address private _credit;
    
    error NotEnoughBalanceOfReader();
    error NotEnoughBalanceOfMarker();
    error NotEnoughBalanceOfVoter();
    
    function permissionsInitialize(PermissionsParams memory params) public {
        _credit = params.credit;
        _reader = params.reader;
        _marker = params.marker;
        _voter = params.voter;
    }
    
    // constructor(address credit_, uint256 reader_, uint256 marker_, uint256 voter_) {
    //     _credit = credit_;
    //     _reader = reader_;
    //     _marker = marker_;
    //     _voter = voter_;
    // }

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
