// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Skylightz is ERC1155, IERC2981, Ownable, Pausable, ReentrancyGuard {
    string public name = "Skylightz";
    string public symbol = "SKY";

    uint256 public price;
    uint256 public royaltyPercent;
    bool public revealed;
    bool public membersReady;
    string private placeholderURI;
    string private baseURI;
    uint256 public allowedSupply;
    uint256 public maxSupply;
    uint256 private currentTokenId;
    string public contractURL;
    address proxyRegistryAddress;
    address[] members;
    uint256[] profits;
    
    constructor(string memory _placeholderURI, string memory _baseURI) ERC1155(string(abi.encodePacked(_baseURI, "{id}.json"))) {
        price = 1000000000000000;
        royaltyPercent = 1000;
        revealed = false;
        membersReady = false;
        placeholderURI = _placeholderURI;
        baseURI = _baseURI;
        allowedSupply = 15;
        maxSupply = 105;
        currentTokenId = 0;
        members = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            members[i] = address(0);
        }
        profits = new uint256[](5);
        for (uint256 i = 0; i < 5; i++) {
            profits[i] = 2000;
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// Owner Functions ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setRoyaltyPercent(uint256 _percent) external onlyOwner {
        royaltyPercent = _percent;
    }

    function setPlaceholderURI(string memory _newPlaceholderURI) public onlyOwner {
        placeholderURI = _newPlaceholderURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setRevealed(bool _value) public onlyOwner {
        revealed = _value;
    }

    function addDailyAllowedSupply() public onlyOwner {
        require(allowedSupply + 10 <= maxSupply, "Daily mint limit ended");

        allowedSupply += 10;
    }

    function setAllowedSupply(uint256 _allowedSupply) public onlyOwner {
        require(_allowedSupply <= maxSupply, "Invalid supply provided");
        require(_allowedSupply >= totalSupply(), "Invalid supply provided");

        allowedSupply = _allowedSupply;
    }

    function setContractURI(string memory _contractURL) public onlyOwner {
        contractURL = _contractURL;
    }

    function setProxyAddress(address _proxyAddress) public onlyOwner {
        proxyRegistryAddress = _proxyAddress;
    }

    function distributeRoyalties() public onlyOwner {
        require(membersReady, "Members are not ready");
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient balance");

        for (uint256 index = 0; index < 5; index++) {
            uint256 amount = (balance * profits[index]) / 10000;
            payable(members[index]).transfer(amount);
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////// Mint Functions ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    function mintMembers(address[] memory _members, uint256[] memory _profits) public onlyOwner {
        require(_members.length == 5, "Invalid members provided");

        for (uint256 index = 0; index < 5; index++) {
            _mint(_members[index], currentTokenId, 1, "");

            members[index] = _members[index];
            profits[index] = _profits[index];
            currentTokenId += 1;
        }

        membersReady = true;
    }

    function mint() external payable {
        require(membersReady, "Members are not ready");
        require(currentTokenId + 1 <= allowedSupply, "Daily mint limited");
        require(msg.value >= price, "Not enough to pay for that");

        for (uint256 index = 0; index < 5; index++) {
            uint256 amount = (msg.value * profits[index]) / 10000;
            payable(members[index]).transfer(amount);
        }
        
        _mint(msg.sender, currentTokenId, 1, "");

        currentTokenId += 1;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// Opensea Functions ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    function totalSupply() public view returns(uint256) {
        return currentTokenId;
    }

    function contractURI() public view returns (string memory) {
        return contractURL;
    }

    function uri(uint256 _tokenId) override public view returns (string memory) {
        require(_tokenId <= allowedSupply - 1, "NFT does not exist");

        if (revealed) {
            return string(abi.encodePacked(baseURI, Strings.toString(_tokenId), ".json"));
        }
        return string(abi.encodePacked(placeholderURI, Strings.toString(_tokenId), ".json"));
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool isOperator) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// Royalty Functions ///////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal whenNotPaused override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_tokenId <= allowedSupply - 1, "NFT does not exist");

        return (address(this), (_salePrice * royaltyPercent) / 10000);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, IERC165) returns (bool) {
        return (
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId)
        );
    }
}
