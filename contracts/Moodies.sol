// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Moodies is ERC721A, ERC721ABurnable, Ownable {
    uint256 public price;
    uint256 public maxQuantity;
    uint256 locked;
    uint256 maxMintableCount;
    uint256 allowListRequired;
    string baseURI;
    address proxyRegistryAddress;
    bytes32 public merkleRoot;
    mapping(address => uint256) private mintedCount;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initPrice,
        uint256 initQuantity,
        string memory uri,
        address proxy
    ) ERC721A(name, symbol) {
        price = initPrice;
        maxQuantity = initQuantity;
        locked = 0;
        maxMintableCount = 5;
        allowListRequired = 0;
        baseURI = uri;
        proxyRegistryAddress = proxy;
    }

    function isOnAllowlist(
        bytes32[] memory _proof,
        address _claimer,
        uint256 _maxMintableCount
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_claimer, _maxMintableCount));
        return MerkleProof.verify(_proof, merkleRoot, leaf);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMaxMintableCount(uint256 _max) public onlyOwner {
        maxMintableCount = _max;
    }

    function setMerkleRootAndMaxMintableCount(
        bytes32 _merkleRoot,
        uint256 _maxMintableCount
    ) public onlyOwner {
        merkleRoot = _merkleRoot;
        maxMintableCount = _maxMintableCount;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setMaxQuantity(uint256 _maxQantity) public onlyOwner {
        require(locked == 0, "Contract is locked.");
        require(
            _maxQantity > _totalMinted(),
            "Cannot set max quantity to less than total minted."
        );
        maxQuantity = _maxQantity;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function lock() public onlyOwner {
        locked = 1;
    }

    // Set allowlisting on/off (1/0)
    function setAllowListRequired(uint256 _value) public onlyOwner {
        allowListRequired = _value;
    }

    function isAllowListRequired() public view returns (uint256) {
        return allowListRequired;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
     * Update it with setProxyAddress
     */
    function setProxyAddress(address _a) public onlyOwner {
        proxyRegistryAddress = _a;
    }

    function airdrop(address[] memory _addresses) public onlyOwner {
        uint256 length = _addresses.length;
        require(
            _totalMinted() + length <= maxQuantity,
            "Cannot mint that many tokens."
        );
        for (uint256 i = 0; i < length; i++) {
            _mint(_addresses[i], 1);
        }
    }

    function currentMintedCount() public view returns (uint256) {
        return mintedCount[msg.sender];
    }

    function mintPublic(uint256 _quantity) external payable {
        require(allowListRequired == 0, "Must use the allow list.");
        require(
            _totalMinted() + _quantity <= maxQuantity,
            "Cannot mint that many tokens."
        );
        require(
            _quantity <= maxMintableCount,
            "Cannot mint that many tokens per call."
        );
        require(
            mintedCount[msg.sender] + _quantity <= maxMintableCount,
            "Cannot mint more."
        );
        require(msg.value == _quantity * price, "Not enough to pay for that");

        _mint(msg.sender, _quantity);

        mintedCount[msg.sender] += _quantity;
    }

    function mintAllowed(
        uint256 _quantity,
        bytes32[] memory _proof,
        uint256 _maxMintableCount
    ) external payable {
        require(allowListRequired == 1, "Allow list is disabled.");
        require(
            isOnAllowlist(_proof, _msgSender(), _maxMintableCount),
            "You are not on the allow list."
        );
        require(
            _totalMinted() + _quantity <= maxQuantity,
            "Cannot mint that many tokens."
        );
        require(
            _quantity <= _maxMintableCount,
            "Cannot mint that many tokens per call."
        );
        require(
            mintedCount[msg.sender] + _quantity <= _maxMintableCount,
            "Cannot mint more."
        );
        require(msg.value == _quantity * price, "Not enough to pay for that");

        _mint(msg.sender, _quantity);

        mintedCount[msg.sender] += _quantity;
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
