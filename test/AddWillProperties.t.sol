// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/Willer.sol";

contract AddWillPropertiesTest is Test {
    Willer public willer;
    address testator;
    address[] beneficiaries;
    uint256[] shares;
    address beneficiaryOfERC721;
    IERC20[] erc20Tokens;

    // Custom errors
    error ArraysLengthMismatch();
    error InvalidBeneficiary();
    error InvalidBeneficiaryOfERC721();
    error InvalidReleaseTimestamp();
    error ShareIsZero();
    error InvalidTestator();
    error NotExist();
    error ShareTooLarge();
    error Unreleasable();
    error WrongTimestamp();
    error ReentrancyError();

    function setUp() public {
        willer = new Willer();
        testator = makeAddr("testator");
        beneficiaryOfERC721 = makeAddr("beneficiaryOfERC721");
        
        // Setup beneficiaries
        for (uint i = 0; i < 5; i++) {
            beneficiaries.push(makeAddr(string.concat("beneficiary", vm.toString(i))));
        }
    }

    function test_RevertWhen_ArrayLengthMismatch() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4]; // One less share than beneficiaries
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(ArraysLengthMismatch.selector));
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
    }

    function test_RevertWhen_BeneficiaryIsZeroAddress() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        beneficiaries[2] = address(0);
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(InvalidBeneficiary.selector));
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
    }

    function test_RevertWhen_ERC721BeneficiaryIsZeroAddress() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(InvalidBeneficiaryOfERC721.selector));
        willer.addWill(beneficiaries, shares, address(0), releaseTime);
    }

    function test_RevertWhen_InvalidReleaseTime() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        uint256 releaseTime = block.timestamp + willer.getBuffer() - 1;
        
        vm.expectRevert(abi.encodeWithSelector(InvalidReleaseTimestamp.selector));
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
    }

    function test_RevertWhen_ShareIsZero() public {
        vm.startPrank(testator);
        shares = [1, 0, 3, 4, 5];
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(ShareIsZero.selector));
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
    }

    function test_RevertWhen_TestatorIsBeneficiary() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        beneficiaries[2] = testator;
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(InvalidTestator.selector));
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
    }

    function test_RevertWhen_WillDoesNotExist() public {
        vm.startPrank(testator);
        
        // Try to modify a non-existent will
        uint256 newReleaseTime = block.timestamp + willer.getBuffer() + 10;
        vm.expectRevert(abi.encodeWithSelector(NotExist.selector));
        willer.setNewReleaseTime(newReleaseTime);
        vm.stopPrank();
    }

    function test_RevertWhen_WillPartiallyExists() public {
        vm.startPrank(testator);
        
        // Create arrays with one invalid entry
        address[] memory invalidBeneficiaries = new address[](1);
        uint256[] memory invalidShares = new uint256[](2); // Different length than beneficiaries
        uint256 newReleaseTime = block.timestamp + willer.getBuffer() + 10;
        
        // Should fail due to array length mismatch
        vm.expectRevert(abi.encodeWithSelector(ArraysLengthMismatch.selector));
        willer.addWill(invalidBeneficiaries, invalidShares, beneficiaryOfERC721, newReleaseTime);
        
        // Should fail because will doesn't exist
        vm.expectRevert(abi.encodeWithSelector(NotExist.selector));
        willer.setNewReleaseTime(newReleaseTime);
        vm.stopPrank();
    }

    function test_RevertWhen_WillPartiallyExistsWithInvalidERC721() public {
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(InvalidBeneficiaryOfERC721.selector));
        willer.addWill(beneficiaries, shares, address(0), releaseTime);
    }

    function test_RevertWhen_WillDoesNotExistAfterFailedAdd() public {
        vm.startPrank(testator);
        uint256 newReleaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(NotExist.selector));
        willer.setNewReleaseTime(newReleaseTime);
        vm.stopPrank();
    }

    function test_GetMaxShare() public {
        assertEq(willer.getMaxShare(), 100);
    }

    function test_RevertWhen_ShareTooLarge() public {
        vm.startPrank(testator);
        
        // Create arrays with share value > MAXSHARE
        address[] memory testBeneficiaries = new address[](1);
        uint256[] memory testShares = new uint256[](1);
        testBeneficiaries[0] = makeAddr("beneficiary");
        testShares[0] = 101; // Greater than MAXSHARE (100)
        
        uint256 newReleaseTime = block.timestamp + willer.getBuffer() + 10;
        
        vm.expectRevert(abi.encodeWithSelector(ShareTooLarge.selector));
        willer.addWill(testBeneficiaries, testShares, beneficiaryOfERC721, newReleaseTime);
        vm.stopPrank();
    }

    function test_RevertWhen_WrongTimestamp() public {
        // Setup a will
        vm.startPrank(testator);
        shares = [1, 2, 3, 4, 5];
        uint256 newReleaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, newReleaseTime);
        
        // First warp to after release time
        vm.warp(newReleaseTime + 1);
        
        // Create a mock ERC20 token array
        erc20Tokens = new IERC20[](1);
        erc20Tokens[0] = IERC20(makeAddr("mockToken"));
        
        // Then warp to timestamp 0
        vm.warp(0);
        
        vm.expectRevert(abi.encodeWithSelector(Unreleasable.selector));
        willer.batchReleaseERC20(testator, erc20Tokens);
        vm.stopPrank();
    }

} 