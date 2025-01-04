// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/Willer.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC721.sol";
import "./mocks/MockERC1155.sol";

contract TokenReleaseTest is Test {
    // Custom errors
    error Unreleasable();
    error WrongTimestamp();
    error NotExist();
    error ReentrancyError();

    Willer public willer;
    address testator;
    address[] beneficiaries;
    uint256[] shares;
    address beneficiaryOfERC721;
    uint256 releaseTime;
    
    MockERC20[] ERC20Tokens;
    MockERC721[] ERC721Tokens;
    MockERC1155[] ERC1155Tokens;
    IERC20[] erc20Tokens;
    IERC721[] erc721Tokens;
    IERC1155[] erc1155Tokens;
    
    uint256 constant N_CONTRACTS = 1;
    uint256 constant N_IDS = 2;
    uint256 constant INITIAL_BALANCE = 1e36;

    function setUp() public {
        willer = new Willer();
        testator = makeAddr("testator");
        beneficiaryOfERC721 = makeAddr("beneficiaryOfERC721");
        releaseTime = block.timestamp + willer.getBuffer() + 10;
        
        // Setup beneficiaries and shares
        shares = [1, 2, 8, 4, 8];
        for (uint i = 0; i < 5; i++) {
            beneficiaries.push(makeAddr(string.concat("beneficiary", vm.toString(i))));
        }

        // Deploy and setup ERC20 tokens
        for (uint i = 0; i < N_CONTRACTS; i++) {
            MockERC20 token = new MockERC20(INITIAL_BALANCE);
            token.transfer(testator, INITIAL_BALANCE);
            ERC20Tokens.push(token);
        }

        // Setup erc20Tokens array
        erc20Tokens = new IERC20[](N_CONTRACTS);
        for (uint i = 0; i < N_CONTRACTS; i++) {
            erc20Tokens[i] = IERC20(address(ERC20Tokens[i]));
        }

        // Deploy and setup ERC721 tokens
        for (uint i = 0; i < N_CONTRACTS; i++) {
            MockERC721 token = new MockERC721();
            for (uint j = 0; j < N_IDS; j++) {
                token.safeMint(testator, j);
            }
            ERC721Tokens.push(token);
        }

        // Setup erc721Tokens array
        erc721Tokens = new IERC721[](N_CONTRACTS);
        for (uint i = 0; i < N_CONTRACTS; i++) {
            erc721Tokens[i] = IERC721(address(ERC721Tokens[i]));
        }

        // Deploy and setup ERC1155 tokens
        for (uint i = 0; i < N_CONTRACTS; i++) {
            MockERC1155 token = new MockERC1155();
            for (uint j = 0; j < N_IDS; j++) {
                token.mint(testator, j, INITIAL_BALANCE, "");
            }
            ERC1155Tokens.push(token);
        }

        // Setup erc1155Tokens array
        erc1155Tokens = new IERC1155[](N_CONTRACTS);
        for (uint i = 0; i < N_CONTRACTS; i++) {
            erc1155Tokens[i] = IERC1155(address(ERC1155Tokens[i]));
        }

        // Setup approvals
        vm.startPrank(testator);
        for (uint i = 0; i < N_CONTRACTS; i++) {
            ERC20Tokens[i].approve(address(willer), INITIAL_BALANCE);
            ERC721Tokens[i].setApprovalForAll(address(willer), true);
            ERC1155Tokens[i].setApprovalForAll(address(willer), true);
        }
        vm.stopPrank();
    }

    function test_BatchReleaseERC20_Unreleasable() public {
        vm.startPrank(testator);
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(Unreleasable.selector));
        willer.batchReleaseERC20(testator, erc20Tokens);
    }

    function test_BatchReleaseERC20_Releasable() public {
        // Setup will
        vm.startPrank(testator);
        releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        // Wait until release time
        vm.warp(releaseTime + 1);
        
        // Release tokens
        willer.batchReleaseERC20(testator, erc20Tokens);

        // Verify balances
        verifyERC20Transfers();
        vm.stopPrank();
    }

    function test_BatchReleaseERC721_Unreleasable() public {
        vm.startPrank(testator);
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        vm.stopPrank();

        uint256[][] memory tokenIds = new uint256[][](ERC721Tokens.length);
        for (uint i = 0; i < ERC721Tokens.length; i++) {
            tokenIds[i] = new uint256[](N_IDS);
            for (uint j = 0; j < N_IDS; j++) {
                tokenIds[i][j] = j;
            }
        }

        vm.expectRevert(abi.encodeWithSelector(Unreleasable.selector));
        willer.batchReleaseERC721(testator, erc721Tokens, tokenIds);
    }

    function test_BatchReleaseERC721_Releasable() public {
        // Setup will
        vm.startPrank(testator);
        releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        // Wait until release time
        vm.warp(releaseTime + 1);
        
        // Release tokens
        uint256[][] memory tokenIds = new uint256[][](ERC721Tokens.length);
        for (uint i = 0; i < ERC721Tokens.length; i++) {
            tokenIds[i] = new uint256[](N_IDS);
            for (uint j = 0; j < N_IDS; j++) {
                tokenIds[i][j] = j;
            }
        }
        
        willer.batchReleaseERC721(testator, erc721Tokens, tokenIds);

        // Verify ownership
        verifyERC721Transfers();
    }

    function test_BatchReleaseERC1155_Unreleasable() public {
        vm.startPrank(testator);
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        vm.stopPrank();

        uint256[] memory tokenIds = new uint256[](N_IDS);
        for (uint j = 0; j < N_IDS; j++) {
            tokenIds[j] = j;
        }

        vm.expectRevert(abi.encodeWithSelector(Unreleasable.selector));
        willer.batchReleaseERC1155(testator, erc1155Tokens[0], tokenIds);
    }

    function test_BatchReleaseERC1155_Releasable() public {
        // Setup will
        vm.startPrank(testator);
        releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        // Wait until release time
        vm.warp(releaseTime + 1);
        
        // Release tokens
        uint256[] memory tokenIds = new uint256[](N_IDS);
        for (uint j = 0; j < N_IDS; j++) {
            tokenIds[j] = j;
        }
        
        willer.batchReleaseERC1155(testator, erc1155Tokens[0], tokenIds);

        // Verify transfers
        verifyERC1155Transfers();
        vm.stopPrank();
    }

    function test_BatchRelease_All() public {
        // Setup will
        vm.startPrank(testator);
        uint256 releaseTime = block.timestamp + willer.getBuffer() + 10;
        willer.addWill(beneficiaries, shares, beneficiaryOfERC721, releaseTime);
        
        // Wait until release time
        vm.warp(releaseTime + 1);

        // Setup arrays for batch release
        IERC20[] memory erc20Array = new IERC20[](ERC20Tokens.length);
        IERC721[] memory erc721Array = new IERC721[](ERC721Tokens.length);
        IERC1155[] memory erc1155Array = new IERC1155[](ERC1155Tokens.length);
        uint256[][] memory erc721Ids = new uint256[][](ERC721Tokens.length);
        uint256[][] memory erc1155Ids = new uint256[][](ERC1155Tokens.length);

        for (uint i = 0; i < ERC20Tokens.length; i++) {
            erc20Array[i] = IERC20(address(ERC20Tokens[i]));
            erc721Array[i] = IERC721(address(ERC721Tokens[i]));
            erc1155Array[i] = IERC1155(address(ERC1155Tokens[i]));
            
            erc721Ids[i] = new uint256[](N_IDS);
            erc1155Ids[i] = new uint256[](N_IDS);
            for (uint j = 0; j < N_IDS; j++) {
                erc721Ids[i][j] = j;
                erc1155Ids[i][j] = j;
            }
        }

        // Batch release all tokens
        willer.batchRelease(
            testator,
            erc20Array,
            erc721Array,
            erc1155Array,
            erc721Ids,
            erc1155Ids
        );

        // Verify all transfers happened correctly
        // This reuses the verification logic from individual tests
        verifyERC20Transfers();
        verifyERC721Transfers();
        verifyERC1155Transfers();
    }

    // Helper functions for verification
    function verifyERC20Transfers() internal {
        for (uint i = 0; i < ERC20Tokens.length; i++) {
            assertEq(ERC20Tokens[i].balanceOf(testator), 0);
            uint256 totalShares = sum(shares);
            
            for (uint j = 0; j < beneficiaries.length; j++) {
                uint256 expectedBalance;
                if (j == beneficiaries.length - 1) {
                    expectedBalance = ERC20Tokens[i].balanceOf(beneficiaries[j]);
                } else {
                    expectedBalance = (INITIAL_BALANCE * shares[j]) / totalShares;
                }
                assertEq(ERC20Tokens[i].balanceOf(beneficiaries[j]), expectedBalance);
            }
        }
    }

    function verifyERC721Transfers() internal {
        for (uint i = 0; i < ERC721Tokens.length; i++) {
            for (uint j = 0; j < N_IDS; j++) {
                assertEq(ERC721Tokens[i].ownerOf(j), beneficiaryOfERC721);
            }
        }
    }

    function verifyERC1155Transfers() internal {
        for (uint i = 0; i < ERC1155Tokens.length; i++) {
            for (uint j = 0; j < N_IDS; j++) {
                assertEq(ERC1155Tokens[i].balanceOf(testator, j), 0);
                uint256 totalShares = sum(shares);
                
                for (uint k = 0; k < beneficiaries.length; k++) {
                    uint256 expectedBalance;
                    if (k == beneficiaries.length - 1) {
                        expectedBalance = ERC1155Tokens[i].balanceOf(beneficiaries[k], j);
                    } else {
                        expectedBalance = (INITIAL_BALANCE * shares[k]) / totalShares;
                    }
                    assertEq(ERC1155Tokens[i].balanceOf(beneficiaries[k], j), expectedBalance);
                }
            }
        }
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