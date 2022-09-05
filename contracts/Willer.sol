// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title Willer
 * @author DimaKush
 *
 */
contract Willer {
    using Math for uint;
    using SafeERC20 for IERC20;

    struct Will {
        address[] beneficiaries;
        uint sumShares;
        address beneficiaryOfERC721;
        uint releaseTime;
        uint[] shares;
    }

    uint buffer = 2;

    mapping(address => Will) public testatorToWill;

    modifier releasable(address _testator) {
        require(
            block.timestamp >= testatorToWill[_testator].releaseTime,
            "Willer: unreleasable"
        );
        _;
    }

    // modifier releasableToTreasury(uint _releaseTime) {
    //     require(
    //         block.timestamp >= _releaseTime,
    //         "Willer: Too early"
    //     );
    //     _;
    // }

    modifier validBeneficiaries(address[] calldata beneficiaries_) {
        for (uint i; i<beneficiaries_.length; i++) {
            require(
            beneficiaries_[i] != address(0), "Willer: address zero is not a valid beneficiary"
            );
        }
        _;
    }

    modifier willExists(address _testator) {
        require(
            (testatorToWill[_testator].releaseTime != 0 &&
                testatorToWill[_testator].beneficiaries.length != 0 &&
                testatorToWill[_testator].beneficiaryOfERC721 != address(0)),
            "Willer: will doesn't exist"
        );
        _;
    }

    modifier sameLengthArrays(address[] calldata beneficiaries_, uint[] calldata shares_) {
        require(
            beneficiaries_.length == shares_.length,
            "Willer: beneficiaries_ and shares_ length mismatch"
        );
        _;
    }

    // add events
    // event ReleasedERC20(address owner, address beneficiary, address tokenERC20Address);
    // event ReleasedERC721(address owner, address beneficiary, address tokenERC721Address);
    // event ReleasedERC1155(address owner, address beneficiary, address tokenERC1155Address);
    // event NewReleaseTime(uint releaseTime);
    // event NewBeneficiary(address beneficiary);

    function addWill(
        address[] calldata beneficiaries_,
        uint[] calldata shares_,
        address beneficiaryOfERC721_,
        uint releaseTime_
    ) public validBeneficiaries(beneficiaries_) sameLengthArrays(beneficiaries_, shares_){
        require(
            releaseTime_ >= block.timestamp + buffer,
            "Willer: invalid release time"
        );

        require(
            beneficiaryOfERC721_ != address(0),
            "Willer: address zero is not a valid beneficiaryOfERC721"
        );
        
        Will storage w = testatorToWill[msg.sender];
        w.beneficiaries = beneficiaries_;
        w.shares = shares_;
        w.sumShares = 0;
        w.beneficiaryOfERC721 = beneficiaryOfERC721_;
        w.releaseTime = releaseTime_;

        for (uint i = 0; i < shares_.length; i++) {
            w.sumShares += shares_[i];
        }
    }

    function getReleaseTime(address testator) public view returns (uint) {
        return testatorToWill[testator].releaseTime;
    }

    function getBeneficiaries(address testator)
        public
        view
        returns (
            address[] memory 
        )
    {
        return testatorToWill[testator].beneficiaries;
    }

    function getShares(address testator) public view returns (uint[] memory) {
        return testatorToWill[testator].shares;
    }

    function getSumShares(address testator) public view returns (uint) {
        return testatorToWill[testator].sumShares;
    }

    function getBeneficiaryOfERC721(address _testator)
        public
        view
        returns (address beneficiaryOfERC721)
    {
        return testatorToWill[_testator].beneficiaryOfERC721;
    }

    // function beforeReleaseTime(address testator)
    //     public
    //     view
    //     returns (uint)
    // {
    //     uint beforeRelease = testatorToWill[testator].releaseTime.sub(block.timestamp);
    //     return beforeRelease;
    // }

    // function afterReleaseTime(address testator)
    //     public
    //     view
    //     returns (uint)
    // {
    //     uint afterRelease = block.timestamp.sub(testatorToWill[testator].releaseTime);
    //     return afterRelease;
    // }

    function setNewBeneficiaries(
        address[] calldata newBeneficiaries,
        uint[] calldata newShares
    ) public willExists(msg.sender) validBeneficiaries(newBeneficiaries) sameLengthArrays(newBeneficiaries, newShares) returns (bool) {
        testatorToWill[msg.sender].beneficiaries = newBeneficiaries;
        testatorToWill[msg.sender].shares = newShares;
        // emit NewBeneficiary(beneficiary);
        return true;
    }

    function setNewReleaseTime(uint newReleaseTime)
        external
        willExists(msg.sender)
        returns (uint)
    {
        require(newReleaseTime != 0, "Willer: newReleaseTime = 0");
        testatorToWill[msg.sender].releaseTime = newReleaseTime;
        // emit NewReleaseTime(testatorToWill[msg.sender]);
        return testatorToWill[msg.sender].releaseTime;
    }

    function setNewBeneficiaryOfERC721(address newBeneficiaryOfERC721)
        public
        willExists(msg.sender)
    {
        testatorToWill[msg.sender].beneficiaryOfERC721 = newBeneficiaryOfERC721;
        // emit NewBeneficiaryOfERC721(beneficiary);
    }

    function releaseERC20(address testator, IERC20 tokenERC20)
        public
        willExists(testator)
        releasable(testator)
    {
        uint balance = tokenERC20.balanceOf(testator);
        uint bequest = 0;
        require(balance != 0, "Willer: No ERC20 tokens to release");
        uint allowed = tokenERC20.allowance(testator, address(this));
        require(allowed != 0, "Willer: ERC20 zero allowance");
        if (allowed < balance) {
            balance = allowed;
        }
        for (
            uint i = 0;
            i < testatorToWill[testator].beneficiaries.length;
            i++
        ) {
            bequest = balance.mulDiv(testatorToWill[testator].shares[i], testatorToWill[testator].sumShares);
            // last beneficiary receives bequest and modulo
            if (i == testatorToWill[testator].beneficiaries.length - 1) {
                bequest = tokenERC20.balanceOf(testator);
            }
            tokenERC20.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaries[i],
                bequest
            );
            // emit ReleasedERC20(testator, beneficiary, tokenERC20);
        }
    }

    function batchReleaseERC20(
        address testator,
        IERC20[] calldata tokenERC20List
    ) external willExists(testator) releasable(testator) {
        for (uint i = 0; i < tokenERC20List.length; i++) {
            this.releaseERC20(testator, tokenERC20List[i]);
        }
    }

    function releaseERC721(
        address testator,
        IERC721 tokenERC721,
        uint[] calldata tokenIdList
    ) external willExists(testator) releasable(testator) {
        for (uint i = 0; i < tokenIdList.length; i++) {
            tokenERC721.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaryOfERC721,
                tokenIdList[i]
            );
        }
        // emit ReleasedERC721(testator, beneficiaryOfERC721, tokenERC721);
    }

    function batchReleaseERC721(
        address testator,
        IERC721[] calldata tokenERC721List,
        uint[][] calldata tokenIdLists
    ) external willExists(testator) releasable(testator) {
        for (uint i = 0; i < tokenERC721List.length; i++) {
            this.releaseERC721(testator, tokenERC721List[i], tokenIdLists[i]);
        }
    }

    function releaseERC1155(
        address testator,
        IERC1155 tokenERC1155,
        uint tokenId
    ) external willExists(testator) releasable(testator) {
        uint balance = tokenERC1155.balanceOf(testator, tokenId);
        uint bequest = 0;
        for (
            uint i = 0;
            i < testatorToWill[testator].beneficiaries.length;
            i++
        ) {
            bequest = balance.mulDiv(testatorToWill[testator].shares[i], testatorToWill[testator].sumShares);
            // last beneficiary receives bequest and modulo
            if (i == testatorToWill[testator].beneficiaries.length - 1) {
                bequest = tokenERC1155.balanceOf(testator, tokenId);
            }
            tokenERC1155.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaries[i],
                tokenId,
                bequest,
                bytes("")
            );
        }
        // emit ReleasedERC1155(testator, beneficiary, address(tokenERC1155));
    }

    function batchReleaseERC1155(
        address testator,
        IERC1155 tokenERC1155,
        uint[] calldata tokenIdLists
    ) external {
        for (uint i = 0; i < tokenIdLists.length; i++) {
            this.releaseERC1155(testator, tokenERC1155, tokenIdLists[i]);
        }
    }

    // Needed?
    function batchRelease(
        address testator,
        IERC20[] calldata tokenERC20List,
        IERC721[] calldata tokenERC721List,
        IERC1155[] calldata tokenERC1155List,
        uint[][] calldata ERC721tokenIdLists,
        uint[][] calldata ERC1155tokenIdLists
    ) external {
        this.batchReleaseERC20(testator, tokenERC20List);
        this.batchReleaseERC721(
            testator,
            tokenERC721List,
            ERC721tokenIdLists
        );
        for (uint i=0; i<tokenERC1155List.length; i++) {
            this.batchReleaseERC1155(
            testator,
            tokenERC1155List[i],
            ERC1155tokenIdLists[i]
        );
        }
    }
}

//if smth fails, just // it ahah=)
