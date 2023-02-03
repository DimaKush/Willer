// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Willer
 * @author DimaKush
 *
 */
contract Willer is Ownable, ReentrancyGuard {
    using Math for uint;
    using SafeERC20 for IERC20;

    struct Will {
        address[] beneficiaries;
        uint sumShares;
        address beneficiaryOfERC721;
        uint releaseTime;
        uint[] shares;
    }

    uint BUFFER = 60;
    uint MIN_BUFFER = 60;
    uint MAXSHARE = 10;
    uint REAP_DELAY = 500000000; //
    address treasuryAddress = address(this);

    mapping(address => Will) private testatorToWill;

    modifier releasable(address _testator) {
        require(
            block.timestamp >= testatorToWill[_testator].releaseTime,
            "Willer: unreleasable"
        );
        _;
    }

    modifier releasableToTreasury(address _testator) {
        require(
            block.timestamp >=
                testatorToWill[_testator].releaseTime + REAP_DELAY,
            "Willer: Too early to reap"
        );
        _;
    }

    modifier validReleaseTime(uint releaseTime_) {
        require(
            releaseTime_ >= block.timestamp + BUFFER,
            "Willer: require( release time > current time + BUFFER )"
        );
        _;
    }

    modifier validBeneficiaryOfERC721(address beneficiaryOfERC721_) {
        require(
            beneficiaryOfERC721_ != address(0),
            "Willer: address zero is not a valid beneficiaryOfERC721"
        );
        _;
    }

    modifier validBeneficiariesAndShares(
        address[] calldata beneficiaries_,
        uint[] calldata shares_,
        address testator_
    ) {
        require(
            beneficiaries_.length == shares_.length,
            "Willer: beneficiaries_ and shares_ length mismatch"
        );

        for (uint i; i < beneficiaries_.length; i++) {
            require(
                beneficiaries_[i] != address(0),
                "Willer: address zero is not a valid beneficiary"
            );
            require(
                beneficiaries_[i] != testator_,
                "Willer: testator is not a valid beneficiary"
            );
            require(
                shares_[i] <= MAXSHARE,
                "Willer: share can't be greater than MAXSHARE"
            );
            require(shares_[i] != 0, "Willer: share can't be 0");
        }
        _;
    }

    modifier validShares(uint[] calldata shares_) {
        for (uint i; i < shares_.length; i++) {
            require(
                shares_[i] <= MAXSHARE,
                "Willer: share can't be greater than MAXSHARE"
            );
            require(shares_[i] >= 0, "Willer: share can't be 0");
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

    modifier sameLengthArrays(
        address[] calldata beneficiaries_,
        uint[] calldata shares_
    ) {
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

    modifier executorIsBeneficiary(address _testator) {
        bool _executorIsBeneficiary = false;
        for (
            uint i = 0;
            i < testatorToWill[_testator].beneficiaries.length;
            i++
        ) {
            if (msg.sender == testatorToWill[_testator].beneficiaries[i]) {
                _executorIsBeneficiary = true;
            }
        }
        if (msg.sender == testatorToWill[_testator].beneficiaryOfERC721) {
            _executorIsBeneficiary = true;
        }

        require(_executorIsBeneficiary, "Willer: executor is not beneficiary");
        _;
    }

    function addWill(
        address[] calldata beneficiaries_,
        uint[] calldata shares_,
        address beneficiaryOfERC721_,
        uint releaseTime_
    )
        public
        validBeneficiariesAndShares(beneficiaries_, shares_, msg.sender)
        validReleaseTime(releaseTime_)
        validBeneficiaryOfERC721(beneficiaryOfERC721_)
        validShares(shares_)
    {
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

    function getBuffer() public view returns (uint) {
        return BUFFER;
    }

    function getReapDelay() public view returns (uint) {
        return REAP_DELAY;
    }

    function getMaxShare() public view returns (uint) {
        return MAXSHARE;
    }

    function getReleaseTime(address testator) public view returns (uint) {
        return testatorToWill[testator].releaseTime;
    }

    function getBeneficiaries(
        address testator
    ) public view returns (address[] memory) {
        return testatorToWill[testator].beneficiaries;
    }

    function getShares(address testator) public view returns (uint[] memory) {
        return testatorToWill[testator].shares;
    }

    function getSumShares(address testator) public view returns (uint) {
        return testatorToWill[testator].sumShares;
    }

    function getBeneficiaryOfERC721(
        address _testator
    ) public view returns (address beneficiaryOfERC721) {
        return testatorToWill[_testator].beneficiaryOfERC721;
    }

    // function timeNow() public view returns(uint) {
    //     return block.timestamp;
    // }

    function setNewBeneficiaries(
        address[] calldata newBeneficiaries,
        uint[] calldata newShares
    )
        public
        willExists(msg.sender)
        validBeneficiariesAndShares(newBeneficiaries, newShares, msg.sender)
        returns (bool)
    {
        testatorToWill[msg.sender].beneficiaries = newBeneficiaries;
        testatorToWill[msg.sender].shares = newShares;
        // emit NewBeneficiary(beneficiary);
        return true;
    }

    function setNewReleaseTime(
        uint newReleaseTime
    )
        external
        willExists(msg.sender)
        validReleaseTime(newReleaseTime)
        returns (uint)
    {
        testatorToWill[msg.sender].releaseTime = newReleaseTime;
        // emit NewReleaseTime(testatorToWill[msg.sender]);
        return testatorToWill[msg.sender].releaseTime;
    }

    function setNewBeneficiaryOfERC721(
        address newBeneficiaryOfERC721
    )
        public
        willExists(msg.sender)
        validBeneficiaryOfERC721(newBeneficiaryOfERC721)
    {
        testatorToWill[msg.sender].beneficiaryOfERC721 = newBeneficiaryOfERC721;
        // emit NewBeneficiaryOfERC721(beneficiary);
    }

    function releaseERC20ToTreasury(
        address testator,
        IERC20 tokenERC20
    ) private {
        uint balance = tokenERC20.balanceOf(testator);
        uint bequest = 0;
        require(balance != 0, "Willer: No ERC20 tokens to release");
        uint allowed = tokenERC20.allowance(testator, address(this));
        require(allowed != 0, "Willer: ERC20 zero allowance");
        if (allowed < balance) {
            balance = allowed;
        }
        tokenERC20.safeTransferFrom(testator, treasuryAddress, balance);
    }

    function releaseERC20(
        address testator,
        IERC20 tokenERC20 // executorIsBeneficiary(testator)
    ) private {
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
            bequest = balance.mulDiv(
                testatorToWill[testator].shares[i],
                testatorToWill[testator].sumShares
            );
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
    )
        external
        willExists(testator)
        releasable(testator)
        executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenERC20List.length; i++) {
            releaseERC20(testator, tokenERC20List[i]);
        }
    }

    function batchReleaseERC20ToTreasury(
        address testator,
        IERC20[] calldata tokenERC20List
    )
        external
        willExists(testator)
        releasableToTreasury(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenERC20List.length; i++) {
            releaseERC20ToTreasury(testator, tokenERC20List[i]);
        }
    }

    function releaseERC721(
        address testator,
        IERC721 tokenERC721,
        uint[] calldata tokenIdList
    )
        private
    {
        for (uint i = 0; i < tokenIdList.length; i++) {
            tokenERC721.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaryOfERC721,
                tokenIdList[i]
            );
        }
        // emit ReleasedERC721(testator, beneficiaryOfERC721, tokenERC721);
    }

    function releaseERC721ToTreasury(
        address testator,
        IERC721 tokenERC721,
        uint[] calldata tokenIdList
    ) private {
        for (uint i = 0; i < tokenIdList.length; i++) {
            tokenERC721.safeTransferFrom(
                testator,
                treasuryAddress,
                tokenIdList[i]
            );
        }
        // emit ReleasedERC721(testator, beneficiaryOfERC721, tokenERC721);
    }

    function batchReleaseERC721(
        address testator,
        IERC721[] calldata tokenERC721List,
        uint[][] calldata tokenIdLists
    )
        external
        willExists(testator)
        releasable(testator)
        executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenERC721List.length; i++) {
            releaseERC721(testator, tokenERC721List[i], tokenIdLists[i]);
        }
    }

    function batchReleaseERC721ToTreasury(
        address testator,
        IERC721[] calldata tokenERC721List,
        uint[][] calldata tokenIdLists
    ) external 
    willExists(testator) 
    releasableToTreasury(testator)
    nonReentrant()
    {
        for (uint i = 0; i < tokenERC721List.length; i++) {
            releaseERC721ToTreasury(
                testator,
                tokenERC721List[i],
                tokenIdLists[i]
            );
        }
    }

    function releaseERC1155(
        address testator,
        IERC1155 tokenERC1155,
        uint tokenId
    )
        internal
    {
        uint balance = tokenERC1155.balanceOf(testator, tokenId);
        uint bequest = 0;
        for (
            uint i = 0;
            i < testatorToWill[testator].beneficiaries.length;
            i++
        ) {
            bequest = balance.mulDiv(
                testatorToWill[testator].shares[i],
                testatorToWill[testator].sumShares
            );
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

    function releaseERC1155ToTreasury(
        address testator,
        IERC1155 tokenERC1155,
        uint tokenId
    ) private {
        uint balance = tokenERC1155.balanceOf(testator, tokenId);
        uint bequest = 0;
        for (
            uint i = 0;
            i < testatorToWill[testator].beneficiaries.length;
            i++
        ) {
            bequest = balance.mulDiv(
                testatorToWill[testator].shares[i],
                testatorToWill[testator].sumShares
            );
            // last beneficiary receives bequest and modulo
            if (i == testatorToWill[testator].beneficiaries.length - 1) {
                bequest = tokenERC1155.balanceOf(testator, tokenId);
            }
            tokenERC1155.safeTransferFrom(
                testator,
                treasuryAddress,
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
    )
        external
        willExists(testator)
        releasable(testator)
        executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenIdLists.length; i++) {
            releaseERC1155(testator, tokenERC1155, tokenIdLists[i]);
        }
    }

    function batchReleaseERC1155ToTreasury(
        address testator,
        IERC1155 tokenERC1155,
        uint[] calldata tokenIdLists
    ) external 
    willExists(testator) 
    releasableToTreasury(testator) 
    nonReentrant()
    {
        for (uint i = 0; i < tokenIdLists.length; i++) {
            releaseERC1155ToTreasury(
                testator,
                tokenERC1155,
                tokenIdLists[i]
            );
        }
    }

    function batchRelease(
        address testator,
        IERC20[] calldata tokenERC20List,
        IERC721[] calldata tokenERC721List,
        IERC1155[] calldata tokenERC1155List,
        uint[][] calldata ERC721tokenIdLists,
        uint[][] calldata ERC1155tokenIdLists
    ) external {
        this.batchReleaseERC20(testator, tokenERC20List);
        this.batchReleaseERC721(testator, tokenERC721List, ERC721tokenIdLists);
        for (uint i = 0; i < tokenERC1155List.length; i++) {
            this.batchReleaseERC1155(
                testator,
                tokenERC1155List[i],
                ERC1155tokenIdLists[i]
            );
        }
    }

    function batchReleaseToTreasury(
        address testator,
        IERC20[] calldata tokenERC20List,
        IERC721[] calldata tokenERC721List,
        IERC1155[] calldata tokenERC1155List,
        uint[][] calldata ERC721tokenIdLists,
        uint[][] calldata ERC1155tokenIdLists
    ) external willExists(testator) releasableToTreasury(testator) {
        this.batchReleaseERC20ToTreasury(testator, tokenERC20List);
        this.batchReleaseERC721ToTreasury(
            testator,
            tokenERC721List,
            ERC721tokenIdLists
        );
        for (uint i = 0; i < tokenERC1155List.length; i++) {
            this.batchReleaseERC1155ToTreasury(
                testator,
                tokenERC1155List[i],
                ERC1155tokenIdLists[i]
            );
        }
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
    }

    function getTreasuryAddress() public view returns (address) {
        return treasuryAddress;
    }
}
