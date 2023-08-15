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
contract Willer is ReentrancyGuard {
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
    uint MAXSHARE = 10;

    mapping(address => Will) private testatorToWill;

    // Event emitted when a new will is added
    event WillAdded(
        address indexed testator,
        address[] beneficiaries,
        uint[] shares,
        address indexed beneficiaryOfERC721,
        uint releaseTime
    );

    // Event emitted when beneficiaries are updated
    event BeneficiariesUpdated(
        address indexed testator,
        address[] newBeneficiaries,
        uint[] newShares
    );

    // Event emitted when the release time is updated
    event ReleaseTimeUpdated(address indexed testator, uint newReleaseTime);

    // Event emitted when the beneficiary of ERC721 token is updated
    event BeneficiaryOfERC721Updated(
        address indexed testator,
        address newBeneficiaryOfERC721
    );

    // Event emitted when ERC20 tokens are released
    event ERC20TokensReleased(
        address indexed testator,
        address indexed beneficiary,
        address tokenERC20Address,
        uint amount
    );

    // Event emitted when ERC721 tokens are released
    event ERC721TokensReleased(
        address indexed testator,
        address indexed beneficiary,
        address tokenERC721Address,
        uint tokenId
    );

    // Event emitted when ERC1155 tokens are released
    event ERC1155TokensReleased(
        address indexed testator,
        address indexed beneficiary,
        address tokenERC1155Address,
        uint tokenId,
        uint amount
    );

    modifier releasable(address _testator) {
        require(
            block.timestamp >= testatorToWill[_testator].releaseTime,
            "Willer: unreleasable"
        );
        require(block.timestamp != 0);
        _;
    }

    modifier validReleaseTime(uint releaseTimestamp_) {
        require(
            releaseTimestamp_ >= block.timestamp + BUFFER,
            "Willer: Invalid release timestamp"
        );
        _;
    }

    modifier validBeneficiaryOfERC721(address beneficiaryOfERC721_) {
        require(
            beneficiaryOfERC721_ != address(0),
            "Willer: zero address  is not a valid beneficiaryOfERC721"
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
                "Willer: 0x0  is not a valid beneficiary"
            );
            require(
                beneficiaries_[i] != testator_,
                "Willer: testator is not a valid beneficiary"
            );
            require(
                shares_[i] <= MAXSHARE,
                "Willer: share can't be greater than MAXSHARE"
            );
            require(shares_[i] > 0, "Willer: share can't be 0");
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
        emit WillAdded(
            msg.sender,
            w.beneficiaries,
            w.shares,
            w.beneficiaryOfERC721,
            w.releaseTime
        );
    }

    function getBuffer() public view returns (uint) {
        return BUFFER;
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

    function setNewBeneficiaries(
        address[] calldata newBeneficiaries,
        uint[] calldata newShares
    )
        public
        willExists(msg.sender)
        validBeneficiariesAndShares(newBeneficiaries, newShares, msg.sender)
    {
        testatorToWill[msg.sender].beneficiaries = newBeneficiaries;
        testatorToWill[msg.sender].shares = newShares;
        emit BeneficiariesUpdated(msg.sender, newBeneficiaries, newShares);
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
        emit ReleaseTimeUpdated(msg.sender, newReleaseTime);
        return testatorToWill[msg.sender].releaseTime;
    }

    function setNewBeneficiaryOfERC721(
        address newBeneficiaryOfERC721
    )
        external
        willExists(msg.sender)
        validBeneficiaryOfERC721(newBeneficiaryOfERC721)
    {
        testatorToWill[msg.sender].beneficiaryOfERC721 = newBeneficiaryOfERC721;
        emit BeneficiaryOfERC721Updated(msg.sender, newBeneficiaryOfERC721);
    }

    function releaseERC20(address testator, IERC20 tokenERC20) private {
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
            emit ERC20TokensReleased(
                testator,
                testatorToWill[testator].beneficiaries[i],
                address(tokenERC20),
                bequest
            );
        }
    }

    function batchReleaseERC20(
        address testator,
        IERC20[] calldata tokenERC20List
    )
        external
        willExists(testator)
        releasable(testator)
        // executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenERC20List.length; i++) {
            releaseERC20(testator, tokenERC20List[i]);
        }
    }

    function releaseERC721(
        address testator,
        IERC721 tokenERC721,
        uint[] calldata tokenIdList
    ) private {
        for (uint i = 0; i < tokenIdList.length; i++) {
            tokenERC721.safeTransferFrom(
                testator,
                testatorToWill[testator].beneficiaryOfERC721,
                tokenIdList[i]
            );
        }
    }

    function batchReleaseERC721(
        address testator,
        IERC721[] calldata tokenERC721List,
        uint[][] calldata tokenIdLists
    )
        external
        willExists(testator)
        releasable(testator)
        // executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenERC721List.length; i++) {
            releaseERC721(testator, tokenERC721List[i], tokenIdLists[i]);
        }
    }

    function releaseERC1155(
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
                testatorToWill[testator].beneficiaries[i],
                tokenId,
                bequest,
                bytes("")
            );
        }
    }

    function batchReleaseERC1155(
        address testator,
        IERC1155 tokenERC1155,
        uint[] calldata tokenIdLists
    )
        external
        willExists(testator)
        releasable(testator)
        // executorIsBeneficiary(testator)
        nonReentrant()
    {
        for (uint i = 0; i < tokenIdLists.length; i++) {
            releaseERC1155(testator, tokenERC1155, tokenIdLists[i]);
        }
    }

    function batchRelease(
        address testator,
        IERC20[] calldata tokenERC20List,
        IERC721[] calldata tokenERC721List,
        IERC1155[] calldata tokenERC1155List,
        uint[][] calldata ERC721tokenIdLists,
        uint[][] calldata ERC1155tokenIdLists
    )
        external
    {
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
}
