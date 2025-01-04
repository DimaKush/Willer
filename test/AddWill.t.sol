// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/Willer.sol";

contract AddWillTest is Test {
    Willer public willer;
    address testator;
    address[] beneficiaries;
    uint256[] shares;
    address beneficiaryOfERC721;
    uint256 constant DELAY = 10;

    function setUp() public {
        willer = new Willer();
        testator = makeAddr("testator");
        beneficiaryOfERC721 = makeAddr("beneficiaryOfERC721");
        
        // Setup beneficiaries array with 5 addresses
        for (uint i = 0; i < 5; i++) {
            beneficiaries.push(makeAddr(string.concat("beneficiary", vm.toString(i))));
            shares.push(i + 1); // Similar to the shares in brownie config
        }

        vm.startPrank(testator);
    }

    function test_AddWill() public {
        // Initial checks
        assertEq(willer.getBeneficiaries(testator).length, 0);
        assertEq(willer.getSumShares(testator), 0);
        assertEq(willer.getReleaseTime(testator), 0);

        // Calculate release time
        uint256 releaseTime = block.timestamp + willer.getBuffer() + DELAY;

        // Add will
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);

        // Verify state changes
        assertEq(willer.getBeneficiaries(testator), beneficiaries);
        assertEq(willer.getSumShares(testator), sum(shares));
        assertEq(willer.getReleaseTime(testator), releaseTime);
    }

    // Helper function to sum array values
    function sum(uint256[] memory array) internal pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < array.length; i++) {
            total += array[i];
        }
        return total;
    }
} 