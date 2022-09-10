// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Ambush is ERC1155, Ownable, ReentrancyGuard {
    string public name = "Ambush";
    string public symbol = "ABS";

    uint256 public price;
    string private baseURI;
    uint8[] private supplies;
    uint256 private maxSupply;
    uint256 private currentTokenId;
    uint256 private maxPerWalletPresale;
    uint256 private maxPerWalletGeneral;
    uint8 private isPresale;
    string public contractURL;
    bytes32 public merkleRoot;
    mapping(address => uint256) private _mintedInPresale;
    mapping(address => uint256) private _mintedInGeneral;

    constructor(uint256 _price, string memory _baseURI) ERC1155(string(abi.encodePacked(_baseURI, "{id}"))) {
        price = _price;
        maxSupply = 2023;
        supplies = new uint8[](maxSupply);
        for (uint256 i = 0; i < maxSupply; i++) {
            supplies[i] = 0;
        }
        baseURI = _baseURI;
        currentTokenId = 0;

        maxPerWalletPresale = 1;
        maxPerWalletGeneral = 2;
        isPresale = 1;
    }

    function isOnAllowlist(bytes32[] memory _proof, address _claimer)
        public
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(_claimer));
        return MerkleProof.verify(_proof, merkleRoot, leaf);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMaxPerWallet(uint256 _maxForPresale, uint256 _maxForGeneral) public onlyOwner {
        maxPerWalletPresale = _maxForPresale;
        maxPerWalletGeneral = _maxForGeneral;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function setIsPresale(uint8 value) public onlyOwner {
        isPresale = value;
    }

    function isInPresale() public view returns (uint8) {
        return isPresale;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setContractURI(string memory _contractURL) public onlyOwner {
        contractURL = _contractURL;
    }

    function airdrop(address _receiver) public onlyOwner {
        require(currentTokenId + 23 <= supplies.length, "NFT is sold out.");

        for (uint256 i = 0; i < 23; i++) {
            require(supplies[currentTokenId] == 0, "NFT is already minted.");
            _mint(_receiver, currentTokenId, 1, "");

            supplies[currentTokenId] += 1;
            currentTokenId += 1;
        }
    }

    function contractURI() public view returns (string memory) {
        return contractURL;
    }

    function totalSupply() public view returns(uint256) {
        return currentTokenId;
    }

    function mintedBalanceOf(address _address, uint8 _isPresale) public view returns (uint256) {
        if (_isPresale == 1) {
            return _mintedInPresale[_address];
        }
        return _mintedInGeneral[_address];
    }

    // For putting NFT on Opensea
    function uri(uint256 _tokenId) override public view returns (string memory) {
        require(_tokenId <= supplies.length - 1, "NFT does not exist");
        return string(abi.encodePacked(baseURI, Strings.toString(_tokenId)));
    }

    function mintPresale(bytes32[] memory _proof) external payable {
        require(isPresale == 1, "It is general sale now.");
        require(isOnAllowlist(_proof, _msgSender()), "You are not on the allow list.");
        require(currentTokenId + 1 <= supplies.length, "NFT is sold out.");
        require(supplies[currentTokenId] == 0, "NFT is already minted.");
        require(_mintedInPresale[_msgSender()] + 1 <= maxPerWalletPresale, "You can not mint anymore.");
        require(msg.value >= price, "Not enough to pay for that");

        _mint(msg.sender, currentTokenId, 1, "");

        supplies[currentTokenId] += 1;
        currentTokenId += 1;
        _mintedInPresale[_msgSender()] = _mintedInPresale[_msgSender()] + 1;
    }

    function mintGeneral() external payable {
        require(isPresale == 0, "It is presale now.");
        require(currentTokenId + 1 <= supplies.length, "NFT is sold out.");
        require(supplies[currentTokenId] == 0, "NFT is already minted.");
        require(_mintedInGeneral[_msgSender()] + 1 <= maxPerWalletGeneral, "You can not mint anymore.");
        require(msg.value >= price, "Not enough to pay for that");

        _mint(msg.sender, currentTokenId, 1, "");

        supplies[currentTokenId] += 1;
        currentTokenId += 1;
        _mintedInGeneral[_msgSender()] = _mintedInGeneral[_msgSender()] + 1;
    }
}
