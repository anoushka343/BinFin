//SPDX-License_Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract SubscriptionModel{
    mapping(uint256 => uint64) internal _expirations;

    /// @notice Emitted when a subscription expiration changes
    /// @dev When a subscription is canceled, the expiration value should also be 0.
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    /// @notice Renews the subscription to an NFT
    /// Throws if `tokenId` is not a valid NFT
    /// @param _tokenId The NFT to renew the subscription for
    /// @param duration The number of seconds to extend a subscription for
    function renewSubscription(
        uint256 _tokenId,
        uint64 duration
    ) external payable {
        uint64 currentExpiration = _expirations[_tokenId];
        uint64 newExpiration;
        if (currentExpiration == 0) {
            //block.timestamp -> Current block timestamp as seconds since unix epoch
            newExpiration = uint64(block.timestamp) + duration;
        } else {
            require(isRenewable(_tokenId), "Subscription Not Renewable");
            newExpiration = currentExpiration + duration;
        }
        _expirations[_tokenId] = newExpiration;
        emit SubscriptionUpdate(_tokenId, newExpiration);
    }

    // /// @notice Cancels the subscription of an NFT
    // /// @dev Throws if `tokenId` is not a valid NFT
    // /// @param _tokenId The NFT to cancel the subscription for
    function cancelSubscription(uint256 _tokenId) external payable {
        delete _expirations[_tokenId];
        emit SubscriptionUpdate(_tokenId, 0);
    }

    // /// @notice Gets the expiration date of a subscription
    // /// @dev Throws if `tokenId` is not a valid NFT
    // /// @param _tokenId The NFT to get the expiration date of
    // /// @return The expiration date of the subscription
    function expiresAt(uint256 _tokenId) external view returns (uint64) {
        return _expirations[_tokenId];
    }

    // /// @notice Determines whether a subscription can be renewed
    // /// @dev Throws if `tokenId` is not a valid NFT
    // /// @param _tokenId The NFT to get the expiration date of
    // /// @return The renewability of a the subscription - true or false
    function isRenewable(uint256 tokenId) public pure returns (bool) {
        return true;
    }
}

contract NftMarketplace is SubscriptionModel, ERC721URIStorage {
    constructor() ERC721("NFT Taco Subscription", "TACO") {
    }

    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    Counters.Counter private nftsAvailableForSale;
    Counters.Counter private userIds;
    struct nftStruct{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        address[] subscribers;
        uint256 likes;
        string title;
        string description;
    }

    struct profileStruct {
        address self;
        address[] followers;
        address[] following;
    }


    mapping(uint256 => nftStruct) private nfts;
    mapping(uint256 => profilesStruct) private profiles;
    event NftStructCreated (
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        address[] subsrcibers,
        uint256 likes,
        string title,
        string description

    );



    /// @dev this function mints received NFTs
    /// @param _tokenURI the new token URI for the taco symbol
    /// @param _title the name of the taco
    /// @_description detailed information on the taco nft
    /// @return tokenID of the created NFT

    function createNft(string memory _tokenURI, string memory _title, string memory _description) public returns(uint256) {
        tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        setNft(newTokenId, _title, _desctipion);
        return newTokenId;
    }

    function setNft(uint256 _tokenId, string memory _title, string memory _description) private {
        nfts[_tokenId].tokenId = _tokenId;
        nfts[_tokenId].seller = payable(msg.sender);
        nfts[_tokenId].owner = payable(msg.sender);
        nfts[_tokenId].price  = 0;
        nfts[_tokenId].subsrcibers = [msg.sender];
        nfts[_tokenId].likes = 1;

        emit NftStructCreated(_tokenId, msg.sender, msg.sender, 0, nfts[_tokenId].subsrcibers,
            nfts[_tokenId].likes, _title, _description);

    }

    /// @dev sell taco subscription to the public so that it's visible to the nft marketplace
    /// @param token_Id the TokenID of the Nft Taco
    /// @param _price the price for the taco subscription
    /// @return total number of available taco subscriptions

    function sellSubscription(uint256 _tokenId, uint256 _price) public returns(uint256) {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "Only NFT owner can perform this");
        _transfer(msg.sender, address(this), tokenId);
        nfts[_tokenId].price = _price;
        nfts[_tokenId].owner = payable(address(this));
        nftsAvailableForSale.increment();
        return nftsAvaialbeForSale.current();
    }

    /// @dev buy a taco subscription from the marketplace
    /// @param _tokenId the TokenID of an NFT Taco
    /// @return true

    function buySubscription(uint256 _tokenId) public payable returns(bool) {
        uint256 price = nfts[_tokenId].price;
        require(msg.value == price, "Please send the asking price");

        payable(nfts[_tokenId].seller).transfer(msg.value);
        nfts[tokenId].subscribers.push(msg.sender);
        return true;
    }

    /// @dev fetch availalbe NFTs on sale that will be displayed on the marketplace
    /// @return nftStruct[] list of nfts with their metadata
    function getSubscriptions() public returns(nftStruct[] memory) {
        uint256 subscriptions = nftsAvailableForSale.current();
        uint256 nftCount = _tokenIds.current();

        nftStruct[] memory nftSubscriptions = new nftStruct[](subscriptions);
        for(uint256 i = 1; i < nftCount; i++) {
            if(nfts[i].owner == address(this)) {
                nftSubscriptions[i] = nfts[i];
            }
        }
        return nftSubscriptions;
    }

    /// @dev fetches NFT magazines that a specific user is alreay subscribed to
    /// @return nftStruct[] list of the nfts colelcts by a user with their metadata

    function getCollectables() public view returns(nftStruct[] memory) {
        uint256 nftCount = tokenIds.current();
        nftStruct[] memory nftSubscriptions;

        for(uint256 i = 1; i < nftCount; i++) {
            uint256 subscriber = nfts[i].subscribers.length;
            for(uint256 j = 0; j < subscribers; j++) {
                if(nfts[i].subscribers[j] == msg.sender) {
                    nftSubscriptions[i] = nfts[i];
                }
            }


        }
        return nftSubscriptions;
    }

    /// @dev gets NFT tacos that a specific user has created
    /// @return nftStruct[] list of nfts created by a user with their metadata

    function getNfts() public view returns(nftStruct[] memory) {
        uint256 nftCount = tokenIds.current();
        nftStruct[] memory nftSubscriptions;
        for (uint256 i = 1; i < nftCount; i++) {
            if(nfts[i].seller == msg.sender) {
                nftSubscriptions[i] = nfts[1];
            }
        }
        return nftSubscriptions;
    }

    /// @dev gets details of a particular NFT taco subscription
    /// @param _tokenId the TokenID of the NFT taco
    /// @return nftStruct NFT data of the specific TokenID

    function getIndividualNFT(uint256 _tokenId) public view returns(nftStruct memory) {
        return nfts[_tokenId];
    }

    /// @notice this represents user onboarding
    /// @dev adds msg.sender as the profile
    /// @return userId and the balance of the msg.sender
    function addProfile() public returns(uint256 userId, uint256 balance){
        userIds.increment();
        uint256 newUserId = userIds.current();
        profiles[newUserId].self = msg.sender;
        userId = newUserId;
        balance = msg.sender.balance;
    }

    /// @dev increment the following tag of the profile performing the action, and the follower tag
    /// of the profile the user wants to follow
    /// @param _account the account the user wants to follow

    function followProfile(address _account) public {
        uint256 totalCount = userIds.current();
        for (uint i = 1; i < totalCount; i++) {
            if(profiles[i].self == payable(msg.sender)) {
                profiles[i].following.push(payable(_account));
            }
            if(profiles[i].self == _account) {
                profiles[i].followers.push(payable(msg.sender));
            }
        }
    }

    // @dev decrement the following tag of the profile performing the action, and the follower tag
    /// that the user wants to unfollow

    function unfollowProfile(address _account) public {
        uint256 totalCount = userIds.current();
        for(uint256 i = 1; i < totalCount; i++) {}
        removeFollowing(profiles[i].self, profiles[i].followers, _account);
        removeFollower(profiles[i].self, profiles[i].following, payable(msg.sender));
    }

    function removeFollowing(address _owner, address[] memory _followers, address _account) private view {
        if (_owner == _account) {
            address[] memory currentFollowing = _followers;
            for(uint256 j = 0; j < currentFollowing.length; j++) {
                if(currentFollowing[j] == payable(msg.sender)) {
                delete currentFollowing[j];
                }
            }
        }
    }

    function removeFollower(address _owner, address[] memory _followers, address _account) private view {
        if(_owner == account) {
            address[] memory currentFollowers = _following;
            for(uint256 j = 0; j < currentFollowers.length; j++) {
                delete currentFollowers[j];
            }
        }
    }

    /// @dev increments number of likes for a NFT Taco by 1
    /// @param _tokenId the TokenID of the NFT Taco
    function likeSubscription(uint256 _tokenId) public {
        nfts[_tokenId].likes += 1;
    }

    /// @dev decrements number of likes for a NFT Taco by 1
    /// @param _tokenId the TokenID of the NFT Taco

    function unlikeSubscription(uint256 _tokenId) public {
        nfts[_tokenId].likes -= 1;
    }
}