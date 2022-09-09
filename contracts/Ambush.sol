// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ambush is ERC721A, ERC721ABurnable, Ownable {
    uint256 public price;
    uint256 public maxQuantity;
    uint256 maxPerWalletPresale;
    uint256 maxPerWalletGeneral;
    uint256 isPresale;
    string contractURL;
    string baseURI;
    bytes32 public merkleRoot;
    mapping(address => uint256) private _mintedInPresale;
    mapping(address => uint256) private _mintedInGeneral;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initPrice,
        string memory uri
    ) ERC721A(name, symbol) {
        price = initPrice;
        maxQuantity = 2023;
        maxPerWalletPresale = 1;
        maxPerWalletGeneral = 2;
        isPresale = 1;
        baseURI = uri;
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

    function setIsPresale(uint256 value) public onlyOwner {
        isPresale = value;
    }

    function isInPresale() public view returns (uint256) {
        return isPresale;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setContractURI(string memory _contractURL) public onlyOwner {
        contractURL = _contractURL;
    }

    function contractURI() public view returns (string memory) {
        return contractURL;
    }

    function mintedBalanceOf(address _address, uint8 _isPresale) public view returns (uint256) {
        if (_isPresale == 1) {
            return _mintedInPresale[_address];
        }
        return _mintedInGeneral[_address];
    }

    function mintGeneral() external payable {
        require(isPresale == 0, "Must use the allow list.");
        require(
            _totalMinted() + 1 <= maxQuantity,
            "Cannot mint that many tokens."
        );
        require(
            _mintedInGeneral[_msgSender()] + 1 <= maxPerWalletGeneral,
            "Cannot mint that many tokens."
        );
        require(msg.value >= price, "Not enough to pay for that");
        _mint(msg.sender, 1);
        _mintedInGeneral[_msgSender()] = _mintedInGeneral[_msgSender()] + 1;
    }

    function mintPresale(bytes32[] memory _proof)
        external
        payable
    {
        require(isPresale == 1, "Allow list is disabled.");
        require(
            isOnAllowlist(_proof, _msgSender()),
            "You are not on the allow list."
        );
        require(
            _totalMinted() + 1 <= maxQuantity,
            "Cannot mint that many tokens."
        );
        require(
            _mintedInPresale[_msgSender()] + 1 <= maxPerWalletPresale,
            "Cannot mint that many tokens."
        );
        require(msg.value >= price, "Not enough to pay for that");
        _mint(msg.sender, 1);
        _mintedInPresale[_msgSender()] = _mintedInPresale[_msgSender()] + 1;
    }
}
