// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ClaimService.sol";
import "./CreditService.sol";
import "./Permissions.sol";

struct ControllerInitializeParams {
    address tokenAddr;
    uint256 reader;
    uint256 marker;
    uint256 voter;
}

contract ControllerV1 is ClaimService, CreditService, Permissions {

    function initialize(ControllerInitializeParams calldata initParams) public {
        tokenAddr = initParams.tokenAddr;
        permissionsInitialize(PermissionsParams({
            credit: initParams.tokenAddr,
            reader: initParams.reader,
            marker: initParams.marker,
            voter: initParams.voter
        }));
    }

    function createMark(string calldata scam) onlyMarker public returns(ErrorCodes) {
        return mark(scam);
    }

    function readMark(string calldata scam) onlyReader public view returns (bytes memory) {
        return readMarkInfo(scam);
    }

    function readMarks(string[] calldata scams) onlyReader public view returns (bytes[] memory) {
        return readMarkInfos(scams);
    }
    
    function voteMark(string calldata scam, bool isAgree, uint256 amount) onlyVoter public returns(ErrorCodes){
        return vote(scam, isAgree, amount);
    }

    function claimMark(bytes32 scamHash) public returns(ErrorCodes) {
        return claim(scamHash);
    }

    function VERSION() public pure returns (string memory) {
        return "0.0.1";
    }
}