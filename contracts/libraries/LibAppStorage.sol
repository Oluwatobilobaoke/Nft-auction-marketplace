// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibERC20} from "./LibERC20.sol";

library LibAppStorage {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    struct AppStorage {
        //ERC20
        string name;
        string symbol;
        uint256 totalSupply;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        //ERC721
        mapping(uint256 tokenId => address) _owners;
        mapping(address owner => uint256) _balances;
        mapping(uint256 tokenId => address) _tokenApprovals;
        mapping(uint256 tokenId => string) tokenURI;
        mapping(address owner => mapping(address operator => bool)) _operatorApprovals;
        //ERC 1155

        // AUCTION MARKETPLACE
        uint256 index;
    }

    enum Categories {
        ERC721,
        ERC1155,
        Both
    }

    struct Auction {
        uint256 index;
        Categories category;
        address addressNFTCollection;
        address addressPaymentToken;
        uint256 nftTokenId;
        address auctionCreator;
        address payable currentBidOwner;
        uint256 currentBidPrice;
        uint256 endAuction;
        uint256 bidCount;
        uint256 minBid;
    }

    // Array to store all the auctions
    Auction[] public allAuctions;

    // event to notify when a new auction is created
    event AuctionCreated(
        uint256 index,
        address addressNFTCollection,
        address addressPaymentToken,
        uint256 nftTokenId,
        address auctionCreator,
        uint256 endAuction,
        uint256 minBid
    );

    // event to notify when a new bid is placed
    event BidPlaced(uint256 index, address bidder, uint256 bidAmount);

    // event to notify when an auction is ended
    event AuctionEnded(uint256 index, address winner, uint256 bidAmount);

    // event when winner claims the NFT
    event NFTClaimed(uint256 index, address winner, uint256 nftTokenId);

    // event when auction creator claims the the token
    event TokenClaimed(
        uint256 index,
        address auctionCreator,
        uint256 nftTokenId
    );

    // event where NFT is transferred to the creator
    event NFTRefund(uint256 index, address auctionCreator, uint256 nftTokenId);

    // ERC20
    function transferFrom(address _from, address _to, uint256 _value) internal {
        AppStorage storage l = getStorage();
        uint256 _allowance = l.allowances[_from][msg.sender];
        if (msg.sender != _from || _allowance < _value) {
            revert("LibAppStorage: transfer amount exceeds allowance");
        }
        l.allowances[_from][msg.sender] = _allowance - _value;

        uint256 frombalances = l.balances[msg.sender];

        l.balances[_from] = frombalances - _value;
        l.balances[_to] += _value;
        emit LibERC20.Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) internal {
        AppStorage storage l = getStorage();
        require(
            l.balances[msg.sender] >= _value,
            "LibAppStorage: transfer amount exceeds balance"
        );
        l.balances[msg.sender] -= _value;
        l.balances[_to] += _value;
        emit LibERC20.Transfer(msg.sender, _to, _value);
    }

    function isContract(
        address _addr
    ) internal view returns (bool addressCheck) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        addressCheck = (size > 0);
    }

    function getStorage() internal pure returns (AppStorage storage l) {
        assembly {
            l.slot := 0
        }
    }
}
