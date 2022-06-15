// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AsyncPlayground is ERC1155, Ownable, ReentrancyGuard {
    enum SALE_TYPE { PRESALE, PUBLICSALE }
    SALE_TYPE private saleType = SALE_TYPE.PRESALE;
    uint8 private PRESALE_MAX_HOLD_COUNT = 1;
    uint8 private PUBLICSALE_MAX_HOLD_COUNT = 5;
    uint8[] private supplies;
    mapping(address => uint) private holdCount;
    address[] private whitelist; 
    uint256 private currentTokenId = 0;
    string public baseURI = "ipfs://QmSCFe5vvoPsSpyHZpGAW78GJ4bAuDcySCV9UnMm7B69iS/";
    
    constructor(uint256 _maxSupply, string memory _baseURI) ERC1155(string(abi.encodePacked(_baseURI, "{id}.json"))) {
        supplies = new uint8[](_maxSupply);
        for (uint256 i = 0; i < _maxSupply; i++) {
            supplies[i] = 0;
        }
        baseURI = _baseURI;
    }

    function isPresale() public view returns(SALE_TYPE) {
        return saleType;
    }

    function setPreSale() public onlyOwner {
        saleType = SALE_TYPE.PRESALE;
    }

    function setPublicSale() public onlyOwner {
        saleType = SALE_TYPE.PUBLICSALE;
    }

    function setBaseUri(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setWhitelist(address[] memory list) public onlyOwner {
        whitelist = list; 
    }

    function checkInWhitelist(address _addr) public view returns(uint8) {
        for (uint256 i = 0 ;i < whitelist.length ; i++){
            if (whitelist[i] == _addr) {
                return 1 ; 
            }
        } 
        return 0 ; 
    }

    function totalSupply() public view returns(uint256) {
        return currentTokenId;
    }

    // For putting NFT on Opensea
    function uri(uint256 _tokenId) override public view returns (string memory) {
        require(_tokenId <= supplies.length - 1, "NFT does not exist");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"));
    }

    function mint() public {
        uint maxHoldCount = PRESALE_MAX_HOLD_COUNT;
        if (saleType == SALE_TYPE.PRESALE) {
            require(checkInWhitelist(msg.sender) == 1, "You are not in the whitelist.");
        } else if (saleType == SALE_TYPE.PUBLICSALE) {
            maxHoldCount = PUBLICSALE_MAX_HOLD_COUNT;
        }

        require(holdCount[msg.sender] <= maxHoldCount, "You can't mint more.");

        require(currentTokenId <= supplies.length - 1, "NFT is sold out.");

        require(supplies[currentTokenId] == 0, "NFT is already minted.");

        _mint(msg.sender, currentTokenId, 1, "");

        currentTokenId += 1;
        supplies[currentTokenId] += 1;
        holdCount[msg.sender] += 1;
    }
}