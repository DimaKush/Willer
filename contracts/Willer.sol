// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
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
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    struct Will {
        address[] beneficiaries;
        uint sumShares;
        address beneficiaryOfERC721;
        uint releaseTime;
        mapping(address => uint) shares;
    }

    uint buffer = 2;

    mapping(address => Will) public testatorToWill;

    modifier releasable(uint _releaseTime) {
        require(
            block.timestamp >= _releaseTime,
            "Willer: Too early for release"
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

    modifier willExists(address _testator) {
        require(
            (testatorToWill[msg.sender].releaseTime != 0 &&
                testatorToWill[msg.sender].beneficiaries.length != 0 &&
                testatorToWill[msg.sender].beneficiaryOfERC721 != address(0)),
            "Willer: will doesn't exist"
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
        address[] memory beneficiaries_,
        uint[] memory shares_,
        address beneficiaryOfERC721_,
        uint releaseTime_
    ) public {
        require(
            beneficiaries_.length == shares_.length,
            "beneficiaries_.length != shares_.length)"
        );
        require(
            releaseTime_ >= block.timestamp + buffer,
            "Willer: Invalid release time"
        );

        Will storage w = testatorToWill[msg.sender];
        w.beneficiaries = beneficiaries_;
        w.sumShares = 0;
        w.beneficiaryOfERC721 = beneficiaryOfERC721_;
        w.releaseTime = releaseTime_;

        for (uint i = 0; i < beneficiaries_.length; i++) {
            w.shares[beneficiaries_[i]] = shares_[i];
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
            address[] memory // calldata?
        )
    {
        return testatorToWill[testator].beneficiaries;
    }

    function getSumShares(address testator) public view returns (uint) {
        return testatorToWill[testator].sumShares;
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

    function setNewBeneficiaries(address[] memory newBeneficiaries)
        public
        willExists(msg.sender)
        returns (bool)
    {
        testatorToWill[msg.sender].beneficiaries = newBeneficiaries;
        // emit NewBeneficiary(beneficiary);
        return true;
    }

    function setNewReleaseTime(uint newReleaseTime)
        public
        willExists(msg.sender)
        returns (bool)
    {
        testatorToWill[msg.sender].releaseTime = newReleaseTime;
        // emit NewBeneficiary(beneficiary);
        return true;
    }

    function setNewBeneficiaryOfERC721(address newBeneficiaryOfERC721)
        public
        willExists(msg.sender)
        returns (bool)
    {
        testatorToWill[msg.sender].beneficiaryOfERC721 = newBeneficiaryOfERC721;
        // emit NewBeneficiaryOfERC721(beneficiary);
        return true;
    }

    function getBeneficiaryOfERC721(address _testator)
        public
        view
        returns (address beneficiaryOfERC721)
    {
        return testatorToWill[_testator].beneficiaryOfERC721;
    }

    function releaseERC20(address testator, IERC20 tokenERC20)
        public
        willExists(testator)
        releasable(testatorToWill[testator].releaseTime)
    {
        uint balance = tokenERC20.balanceOf(testator);
        require(balance != 0, "No ERC20 tokens to release");
        uint allowed = tokenERC20.allowance(testator, address(this));
        require(allowed != 0, "ERC20 zero allowance");
        if (allowed < balance) {
            balance = allowed;
            for (
                uint i = 0;
                i < testatorToWill[testator].beneficiaries.length;
                i++
            ) {
                tokenERC20.safeTransferFrom(
                    testator,
                    testatorToWill[testator].beneficiaries[i],
                    balance.div(getSumShares(testator)).mul(
                        testatorToWill[testator].shares[
                            testatorToWill[testator].beneficiaries[i]
                        ]
                    )
                );
                // emit ReleasedERC20(testator, beneficiary, address(tokenERC20));
            }
        }
    }

    function batchReleaseERC20(
        address testator,
        IERC20[] calldata tokenERC20List
    ) public {
        require(
            block.timestamp >= getReleaseTime(testator),
            "Current time is before release time"
        );

        for (uint i = 0; i < tokenERC20List.length; i++) {
            this.releaseERC20(testator, tokenERC20List[i]);
        }
    }

    function releaseERC721(
        address testator,
        IERC721 tokenERC721,
        uint[] calldata tokenIdList
    ) public {
        require(
            block.timestamp >= getReleaseTime(testator),
            "Current time is before release time"
        );
        for (uint i = 0; i < tokenIdList.length; i++) {
            tokenERC721.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaryOfERC721,
                tokenIdList[i]
            );
        }
        // emit ReleasedERC721(testator, beneficiaryOfERC721, address(tokenERC721));
    }

    //    function batchReleaseERC721(address testator, address beneficiary, IERC721[] calldata tokenERC721List,
    //        uint[][] calldata tokenIdLists)
    //    external {
    //
    //        for (uint i = 0; i < tokenERC721List.length; i++) {
    //            if (testatorToWill[testator].ERC721ToIdToBeneficiary[tokenERC721List[i]][tokenIdLists[i]])
    //            this.releaseERC721(testator, beneficiary, tokenERC721List[i], tokenIdLists[i]);
    //        }
    //    }

    //     function releaseERC1155(
    //         address testator,
    //         IERC1155 tokenERC1155,
    //         uint[] calldata tokenIdList,
    //         uint[] calldata values
    //     ) external {
    //         require(
    //             block.timestamp >= testatorToWill[testator].releaseTime,
    //             "Current time is before release time"
    //         );
    //         require (tokenIdList.length == values.length, "tokenIdList.length != values.length,");
    //         // uint[] memory releasableValues = values
    //         for (uint n = 0; n < testatorToWill[testator].beneficiaries; n++) {
    //             tokenERC1155.safeBatchTransferFrom(
    //             testator,
    //             testatorToWill[testator].beneficiaries[n],
    //             tokenIdList,
    //             values.mul(testatorToWill[testator].shares[testatorToWill[testator].beneficiaries[n]]).div(testatorToWill[testator].sumShares),
    //             bytes("")
    //         );
    //         // emit ReleasedERC1155(testator, beneficiary, address(tokenERC1155));
    //         }
    //     }
    //     function batchReleaseERC1155(
    //         address testator,
    //         IERC1155[] calldata tokenERC1155List,
    //         uint[][] calldata tokenIdLists,
    //         uint[][] calldata valuesLists
    //     ) external {
    //         for (uint i = 0; i < tokenERC1155List.length; i++) {
    //             this.releaseERC1155(
    //                 testator,
    //                 tokenERC1155List[i],
    //                 tokenIdLists[i],
    //                 valuesLists[i]
    //             );
    //         }
    //     }
    //     // function batchRelease(
    //     //     address testator,
    //     //     address beneficiary,
    //     //     IERC20[] calldata tokenERC20List,
    //     //     IERC721[] memory tokenERC721List,
    //     //     IERC1155[] memory tokenERC1155List,
    //     //     uint[][] memory ERC721tokenIdLists,
    //     //     uint[][] memory ERC1155tokenIdLists,
    //     //     uint[][] memory valuesLists
    //     // ) external {
    //     //     this.batchReleaseERC20(testator, beneficiary, tokenERC20List);
    //     //     this.batchReleaseERC721(
    //     //         testator,
    //     //         beneficiary,
    //     //         tokenERC721List,
    //     //         ERC721tokenIdLists
    //     //     );
    //     //     this.batchReleaseERC1155(
    //     //         testator,
    //     //         beneficiary,
    //     //         tokenERC1155List,
    //     //         ERC1155tokenIdLists,
    //     //         valuesLists
    //     //     );
    //     // }
}
