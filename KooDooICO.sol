// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./interfaces/Aggregator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract KooDooICO is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    event TokenBuyed(address indexed to, uint256 amount);
    event TokenPerUSDPriceUpdated(uint256 amount);
    event PaymentTokenDetails(tokenDetail);
    event TokenAddressUpdated(address indexed tokenAddress);
    event ReferralAdded(address indexed referrer, address indexed referredUser);
    event SignerAddressUpdated(
        address indexed previousSigner,
        address indexed newSigner
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    mapping(uint256 => tokenDetail) public paymentDetails;
    mapping(uint256 => bool) usedNonce;

    IERC20 public tokenAddress;

    uint256 public totalSaleVolume;

    uint256 public startDate;
    uint256 public _firstRoundEndDate;
    uint256 public _secondRoundEndDate;
    uint256 public _thirdRoundEndDate;

    uint256 _firstRoundPrice;
    uint256 _secondRoundPrice;
    uint256 _thirdRoundPrice;
    uint256 _finalPrice;

    uint256 _firstRoundSaleVolume;
    uint256 _secondRoundSaleVolume;
    uint256 _thirdRoundSaleVolume;

    address public signer;
    address public owner;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    struct tokenDetail {
        string paymentName;
        address priceFetchContract;
        address paymentTokenAddress;
        uint256 decimal;
        bool status;
    }

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    enum  Round {
        First,
        Second,
        Third,
        Final
    }

    struct userReferral {
        address referrer;
        address[] referralAddresses;
        uint256 totalReferralAmount;
        uint256 referralCount;
    }

mapping(address => userReferral) public userReferrals;

constructor(address _ownerAddress, address _signerAddress, IERC20 _tokenAddress,  uint256 _startdate) {
    owner = _ownerAddress;
    signer = _signerAddress;
    tokenAddress = _tokenAddress;
    startDate = block.timestamp + _startdate;
    _firstRoundEndDate = startDate +  30 minutes;
    _secondRoundEndDate = _firstRoundEndDate + 30 minutes;
    _thirdRoundEndDate = _secondRoundEndDate + 30 minutes;
    _firstRoundPrice = 5000000000000;
    _secondRoundPrice = 3333333333300;
    _thirdRoundPrice = 2500000000000;
    _finalPrice = 2000000000000;
    _firstRoundSaleVolume = 1000;
    _secondRoundSaleVolume = 3000;
    _thirdRoundSaleVolume = 5000;
    _grantRole(ADMIN_ROLE, owner);
    _grantRole(SIGNER_ROLE, signer);

    paymentDetails[0] = tokenDetail(
        "BNB",
        0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526,
        0x0000000000000000000000000000000000000000,
        18,
        true
    );

    // USDT token on BSC
    paymentDetails[1] = tokenDetail(
        "BUSD",
        0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa, 
        0xd4A9a6553f877f55f2B645ce749a94bc830363EE, 
        18,
        true
    );

}


    /**
     * @dev Transfers ownership of the contract to a new address.
     * @param newOwner The address of the new owner.
     */

    function transferOwnership(address newOwner)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(newOwner != address(0), "Invalid Address");
        _revokeRole(ADMIN_ROLE, owner);
        address oldOwner = owner;
        owner = newOwner;
        _grantRole(ADMIN_ROLE, owner);
        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * @dev Sets the signer address for verifying signatures.
     * @param signerAddress The address of the new signer.
     */
    function setSignerAddress(address signerAddress)
        external
        onlyRole(SIGNER_ROLE)
    {
        require(signerAddress != address(0), "Invalid Address");
        _revokeRole(SIGNER_ROLE, signer);
        address oldSigner = signer;
        signer = signerAddress;
        _grantRole(SIGNER_ROLE, signer);
        emit SignerAddressUpdated(oldSigner, signer);
    }
    /**
     * @dev Returns the current price of the token in USD based on the payment type.
     * @param paymentType The type of payment (0 for BNB, 1 for token).
     * @return int256 The latest price of the token in USD.
     */

    function getLatestPrice(uint256 paymentType) public view returns(int256) {
        (, int256 price, , , ) = AggregatorV3Interface(
            paymentDetails[paymentType].priceFetchContract
        ).latestRoundData();
        return price;
    }

    function getReferralDetails(address user) public view returns (userReferral memory) {
        return userReferrals[user];
    }
    /**
     * @dev Adds a referral for the user.
     * @param referrer The address of the referrer.
     * @return bool indicating success or failure.
     */


    function addReferral(address referrer) internal returns (bool) {
        require(referrer != address(0), "Invalid referrer address");
        require(referrer != msg.sender, "Cannot refer yourself");
        userReferral storage referral = userReferrals[referrer];
        referral.referralAddresses.push(msg.sender);
        if (referral.referrer == address(0)) {
            userReferrals[msg.sender].referrer = referrer; // Set the referrer if not already set
        }
        referral.referralCount = referral.referralAddresses.length;
        referral.totalReferralAmount += referral.totalReferralAmount;
        userReferrals[referrer] = referral; // Store the referral data for the user
        emit ReferralAdded(referrer, msg.sender); // Emit an event for the referral action
        return true;  
    }
    /** * @dev Allows users to buy tokens using either BNB or a specified token.
     * @param recipient The address that will receive the purchased tokens.
     * @param referrer The address of the referrer, if any.
     * @param paymentType The type of payment (0 for BNB, 1 for token).
     * @param tokenAmount The amount of tokens to purchase (if using a token).
     * @param sign The signature details for verification.
     */

    function buyToken(
        address recipient,
        address referrer,
        uint256 paymentType,
        uint256 tokenAmount,
        Sign memory sign
    ) external payable nonReentrant {
        require(paymentDetails[paymentType].status, "Invalid Payment");
        require(!usedNonce[sign.nonce], "Invalid Nonce");
        require(tokenAddress.balanceOf(address(this)) > 0, "ICO:All sale rounds ended or volume limits exceeded");
        usedNonce[sign.nonce] = true;
        uint256 amount;
        if (paymentType == 0) {
            require(msg.value > 0 , "Invalid amount");
            verifySign(paymentType, recipient, msg.sender, msg.value, sign);
            amount = getToken(paymentType, msg.value);
        } else {
            require(tokenAmount > 0, "Invalid token amount");
            verifySign(paymentType, recipient, msg.sender, tokenAmount, sign);
            amount = getToken(paymentType, tokenAmount);
            IERC20(paymentDetails[paymentType].paymentTokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                tokenAmount
            );
        }
        if(getCurrentSaleStage() == Round.First) {
            uint256 _refBonus = amount * 10 / 100; // 10% referral bonus
            if (referrer != address(0) && referrer != msg.sender) {
                if(userReferrals[referrer].referrer == address(0)) {
                    addReferral(referrer);
                }
                userReferrals[referrer].totalReferralAmount += _refBonus;
                IERC20(tokenAddress).safeTransfer(referrer, _refBonus);
            }        
        } 
        tokenAddress.safeTransfer(recipient, amount);
        totalSaleVolume += (amount/1e12);
        emit TokenBuyed(msg.sender, amount);
    }
    /** * @dev Allows users to buy tokens using either BNB or a specified token.
     * @param paymentType The type of payment (0 for BNB, 1 for token).
     * @param tokenAmount The amount of tokens to purchase (if using a token).
     * @return data The calculated amount of tokens to be purchased.
     */
   
    function getToken(uint256 paymentType, uint256 tokenAmount)
        public
        view
        returns (uint256 data)
    {
        uint256 price = uint256(getLatestPrice(paymentType));
        uint256 amount = price *  _getTokenPrice() / 1e8;
        data = amount * tokenAmount / (10 ** paymentDetails[paymentType].decimal);
        if( _getSaleRound() == Round.First) {
            require(data >= 5000 * 1e12, "ICO: Round 1 minimum purchase is 5000 tokens");
        }
    }

    /** * @dev Returns the current sale stage based on the elapsed time and total sale volume.
     * @return Round The current sale stage (First, Second, Third, or Final).
     */

    function getCurrentSaleStage() public view returns (Round) {
        return _getSaleRound();
    }

    /** * @dev Internal function to determine the current sale round based on elapsed time and total sale volume.
     * @return Round The current sale round (First, Second, Third, or Final).
     */

    function _getSaleRound()  internal view returns (Round) {
        uint256 elapsed = block.timestamp;

        // Round 1
        if (elapsed <= _firstRoundEndDate && totalSaleVolume <= _firstRoundSaleVolume) {
            return Round.First;
        }

        // Round 2
        if ((elapsed <= _secondRoundEndDate || totalSaleVolume >= _firstRoundSaleVolume) &&
            totalSaleVolume <= _secondRoundSaleVolume) {
            return Round.Second;
        }

        // Round 3
        if ((elapsed <= _thirdRoundEndDate || totalSaleVolume >= _secondRoundSaleVolume) &&
            totalSaleVolume <= _thirdRoundSaleVolume) {
            return Round.Third;
        }
        return Round.Final;
        
    }
    /** * @dev Returns the price of the token based on the current sale round.
     * @return uint256 The price of the token in wei.
     */


    function _getTokenPrice() public view returns (uint256) {
        // Round 1
        if (_getSaleRound() == Round.First) {
            return _firstRoundPrice;
        }
        // Round 2
        if (_getSaleRound() == Round.Second) {
            return _secondRoundPrice;
        }
        // Round 3
        if (_getSaleRound() == Round.Third) {
            return _thirdRoundPrice;
        }
        // Final price
        if (_getSaleRound() == Round.Final) {
            return _finalPrice;
        }
        // Default case, should not happen
        return _finalPrice;
    }   

    /** * @dev Allows the contract owner to recover BNB from the contract.
     * @param walletAddress The address to which the BNB will be sent.
     */
    // Function to recover BNB from the contract

    function recoverBNB(address walletAddress)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(walletAddress != address(0), "Null address");
        uint256 balance = address(this).balance;
        payable(walletAddress).transfer(balance);
    }
    /** * @dev Allows the contract owner to recover tokens from the contract.
     * @param _tokenAddress The address of the token to be recovered.
     * @param walletAddress The address to which the tokens will be sent.
     * @param amount The amount of tokens to be recovered.
     */

    function recoverToken(address _tokenAddress,address walletAddress, uint256 amount)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(walletAddress != address(0), "Null address");
        require(amount <= IERC20(_tokenAddress).balanceOf(address(this)), "Insufficient amount");
        IERC20(_tokenAddress).safeTransfer(
            walletAddress,
            amount
        );
    }

    /** * @dev Allows the contract owner to set the payment token details.
     * @param paymentType The type of payment (0 for BNB, 1 for token).
     * @param _tokenDetails The details of the payment token.
     */

    function setPaymentTokenDetails(uint256 paymentType, tokenDetail memory _tokenDetails)
        external
        onlyRole(ADMIN_ROLE)
    {
        paymentDetails[paymentType] = _tokenDetails;
        emit PaymentTokenDetails(_tokenDetails);
    }

    /** * @dev Allows the contract owner to set the token address.
     * @param _tokenAddress The address of the token to be set.
     */

    function setTokenAddress(address _tokenAddress)
        external
        onlyRole(ADMIN_ROLE)
    {
        tokenAddress = IERC20(_tokenAddress);
        emit TokenAddressUpdated(address(tokenAddress));
    }
    /** * @dev Allows the contract owner to set the price of the token in USD.
     * @param tokenAmount The amount of tokens to be set as the price.
     */

    function setTokenPricePerUSD(uint256 tokenAmount)
        external
        onlyRole(ADMIN_ROLE)
    {
        // Round 1
        if (_getSaleRound() == Round.First) {
            _firstRoundPrice = tokenAmount;
        }
        // Round 2
        if (_getSaleRound() == Round.Second) {
            _secondRoundPrice = tokenAmount;
        }
        // Round 3
        if (_getSaleRound() == Round.Third) {
             _thirdRoundPrice = tokenAmount;
        }
        // Final price
        if (_getSaleRound() == Round.Final) {
             _finalPrice = tokenAmount;
        }
        // Default case, should not happen
        _finalPrice = tokenAmount;
    }
    /** * @dev Verifies the signature of the owner for the given parameters.
     * @param assetType The type of asset being purchased (0 for BNB, 1 for token).
     * @param recipient The address that will receive the purchased tokens.
     * @param caller The address of the caller (buyer).
     * @param amount The amount of tokens being purchased.
     * @param sign The signature details for verification.
     */

    function verifySign(
        uint256 assetType,
        address recipient,
        address caller,
        uint256 amount,
        Sign memory sign
    ) internal view {
        bytes32 hash = keccak256(
            abi.encodePacked(assetType, recipient, caller, amount, sign.nonce)
        );
        require(
            signer ==
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    sign.v,
                    sign.r,
                    sign.s
                ),
            "Owner sign verification failed"
        );
    }

}