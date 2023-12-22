// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Credit} from "../src/Credit.sol";

contract CreditTest is Test {
    uint256 private constant MAXIMUM_SUPPLY = 21_000_000 * 10 ** 18;

    Credit public creditToken;

    function setUp() public {
        creditToken = new Credit(MAXIMUM_SUPPLY);
    }

    function test_maxiumSupply_equal_to_MAXUMUM_SUPPLY() public {
        assertEq(creditToken.maximumSupply(), MAXIMUM_SUPPLY);
    }

    function test_when_mint_then_balance_increases() public {
        address user = makeAddr("user");
        uint256 amount = 100 * 10 ** creditToken.decimals();

        creditToken.mint(user, amount);

        assertEq(creditToken.balanceOf(user), amount);
    }

    function test_when_mint_then_totalSupply_increases() public {
        creditToken.mint(address(this), 100e18);

        assertEq(creditToken.totalSupply(), 100e18);
    }

    function test_when_mint_exceeds_maximumSupply_then_revert() public {
        uint256 exceededAmount = MAXIMUM_SUPPLY + 1e18;

        vm.expectRevert("Maximum supply exceeded");
        creditToken.mint(address(this), exceededAmount);
    }
}
