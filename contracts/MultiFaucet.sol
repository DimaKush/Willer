// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721mint is IERC721 {
    function safeMint(
        address to,
        string memory uri
    ) external;
}

interface IERC1155mint is IERC1155 {
    function setURI(string memory newuri) external;

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        external;
        
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external;
}


contract MultiFaucet is Ownable {
    IERC20 ERC20;
    IERC721mint ERC721;
    IERC1155mint ERC1155;
    
    mapping(address=>uint256) nextRequestAt;
    
    uint256 faucetDripAmount = 1000;
    uint256 cooldown = 1 hours;
    uint256[] IDs = [0, 1];
    uint256[] AMMOUNTS = [faucetDripAmount, faucetDripAmount * 7];
    string URI = 'https://ipfs.io/ipfs/Qmf7VNoB52ngDMfehjZDnojVfbDmrMqgQQFfZS2V12VdXk?filename=IMG_20210214_185956.jpg';
    
    constructor (address _ERC20Address, address _ERC721Address, address _ERC1155Address) {
        ERC20 = IERC20(_ERC20Address);
        ERC721 = IERC721mint(_ERC721Address);
        ERC1155 = IERC1155mint(_ERC1155Address); 
    }   

    function getCooldown() public view returns (uint256) {
        return cooldown;
    }

    function getURI() public view returns (string memory) {
        return URI;
    }
     
    // Sends the amount of token to the caller.
    function drip() external {
        require(ERC20.balanceOf(address(this)) > 1,"MF: Empty ERC20");
        require(nextRequestAt[msg.sender] < block.timestamp, "MF: Try again later");
        
        // Next request from the address can be made only after cooldown         
        nextRequestAt[msg.sender] = block.timestamp + (cooldown); 
        
        ERC20.transfer(msg.sender,faucetDripAmount * 10**18);
        ERC721.safeMint(msg.sender, URI);
        ERC1155.mintBatch(msg.sender, IDs, AMMOUNTS, '');
    }  
    function setCooldown(uint256 _cooldown) external onlyOwner {
        cooldown = _cooldown;        
    }

    function setURI(string calldata _URI) external onlyOwner {
        URI = _URI;        
    }

     function setERC20Address(address _ERC20Addr) external onlyOwner {
        ERC20 = IERC20(_ERC20Addr);
    }    

     function setERC721Address(address _ERC721Addr) external onlyOwner {
        ERC721 = IERC721mint(_ERC721Addr);
    }   

     function setERC1155Address(address _ERC1155Addr) external onlyOwner {
        ERC1155 = IERC1155mint(_ERC1155Addr);
    }    
        
     function setFaucetDripAmount(uint256 _amount) external onlyOwner {
        faucetDripAmount = _amount;
    }  
     
     function withdrawERC20(address _receiver, uint256 _amount) external onlyOwner {
        require(ERC20.balanceOf(address(this)) >= _amount,"MF: Insufficient ERC20 tokens");
        ERC20.transfer(_receiver,_amount);
    }    
}