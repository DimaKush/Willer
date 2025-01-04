// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiFaucet is Ownable {
    mapping(address => uint256) public lastDripTime;
    uint256 public constant DRIP_INTERVAL = 1 days;
    uint256 public constant ERC20_AMOUNT = 1000 * 10**18;
    uint256 public constant ERC1155_AMOUNT = 1000;

    event TokensDripped(address indexed recipient, address indexed token);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function dripERC20(IERC20 token) external {
        require(
            block.timestamp >= lastDripTime[msg.sender] + DRIP_INTERVAL,
            "MultiFaucet: too soon"
        );
        lastDripTime[msg.sender] = block.timestamp;
        
        require(
            token.transfer(msg.sender, ERC20_AMOUNT),
            "MultiFaucet: transfer failed"
        );
        
        emit TokensDripped(msg.sender, address(token));
    }

    function dripERC721(IERC721 token, uint256 tokenId) external {
        require(
            block.timestamp >= lastDripTime[msg.sender] + DRIP_INTERVAL,
            "MultiFaucet: too soon"
        );
        lastDripTime[msg.sender] = block.timestamp;
        
        token.transferFrom(address(this), msg.sender, tokenId);
        
        emit TokensDripped(msg.sender, address(token));
    }

    function dripERC1155(
        IERC1155 token,
        uint256 id,
        bytes memory data
    ) external {
        require(
            block.timestamp >= lastDripTime[msg.sender] + DRIP_INTERVAL,
            "MultiFaucet: too soon"
        );
        lastDripTime[msg.sender] = block.timestamp;
        
        token.safeTransferFrom(
            address(this),
            msg.sender,
            id,
            ERC1155_AMOUNT,
            data
        );
        
        emit TokensDripped(msg.sender, address(token));
    }

    function withdrawERC20(IERC20 token, uint256 amount) external onlyOwner {
        require(
            token.transfer(msg.sender, amount),
            "MultiFaucet: transfer failed"
        );
    }

    function withdrawERC721(IERC721 token, uint256 tokenId) external onlyOwner {
        token.transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawERC1155(
        IERC1155 token,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        token.safeTransferFrom(address(this), msg.sender, id, amount, data);
    }
} 