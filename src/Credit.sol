// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Credit is ERC20 {
    uint256 private _maximumSupply;

    constructor(uint256 maximumSupply_) ERC20("Credit", "CRE") {
        _maximumSupply = maximumSupply_;
    }

    function maximumSupply() public view returns (uint256) {
        return _maximumSupply;
    }

    function mint(address to, uint256 amount) public {
        require(totalSupply() + amount <= _maximumSupply, "Maximum supply exceeded");
        _mint(to, amount);
    }
}
