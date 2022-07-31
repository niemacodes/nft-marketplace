//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {

    // define owner: 
    address payable owner;

    // getting counters implementation: 
    // will use this to define a few more vars:
    using Counters for Counters.Counter;

    // stored vars:
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // ether: special keyword in solidity:
    uint256 listPrice = 0.01 ether;

    // constructor: 
    // pass in name of class + the acronym you want to save it as:
    // pass in the owner  
    constructor() ERC721("NFTMarketplace", "NFTM"){

        // users will have to pay a small fee: 
        owner = payable(msg.sender);
    }

    // struct that stores the listed token:
    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    // mapping an address to a listed token:   
    mapping(uint256 => ListedToken) private idToListedToken;  

    function updateListPrice(uint256 _listPrice) public payable{
         require(owner == msg.sender, "Only owner can update the listing price");
         listPrice = _listPrice;
    }

    function getListPrice() public view returns (uint256){
        return listPrice;
    }

    function getLatestIdToListedToken() public view returns (ListedToken memory){
        // fetch latest token id:
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    function getListedForTokenId(uint256 tokenId) public view returns (ListedToken memory){
        return idToListedToken[tokenId]; 
    }

    function getCurrentToken() public view returns (uint256){
        return _tokenIds.current();
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns (uint){

        // check if enough funds were sent by the user:
        require(msg.value == listPrice, "Send enough ether to list");

        // check if cost isn't negative
        require(price > 0, "Make sure the price isn't negative");

        // Increment token ID & mint it:
        _tokenIds.increment();
        uint256 currentTokenId = _tokenIds.current();
        _safeMint(msg.sender, currentTokenId);

        // set token URI:
        _setTokenURI(currentTokenId, tokenURI);
    
        createListedToken(currentTokenId, price);

        return currentTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        idToListedToken[tokenId] = ListedToken(
            tokenId, 
            payable(address(this)),
            payable(msg.sender),
            price, 
            true
        );

        // transfer ownership:
        _transfer(msg.sender, address(this), tokenId);
    }

    function getAllNFTs() public view returns(ListedToken[] memory){
        
        // Get exact counts of items in array:
        uint nftCount = _tokenIds.current();

        // Create a listed token arr:
        ListedToken[] memory tokens = new ListedToken[](nftCount);

        uint currentIndex = 0;

        for(uint i = 0; i < nftCount; i++){
            uint currentId = i+1;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        
        return tokens;
    }

    function getMyNFTs() public view returns(ListedToken[] memory){
        // Get exact counts of items in array:
        uint totelItemCounts = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 0; i < totelItemCounts; i++){
            if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
                itemCount += 1;
            }
        }
        
        // Create a listed token arr:
        ListedToken[] memory tokens = new ListedToken[](itemCount);
        for(uint i = 0; i < totelItemCounts; i++){
            if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
                uint currentId = i+1;
                ListedToken storage currentItem = idToListedToken[currentId];
                tokens[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
    
        return tokens;
    }
}