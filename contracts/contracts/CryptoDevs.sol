// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAllowlist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    /**
     * @dev _baseTokenURI computes {tokenURI}. When set, the resulting URI for
     * each token will be the concatenation of the `baseURI` and the `tokenId`
     */
    string _baseTokenURI;

    // _price defines the price of one NFT
    uint256 public _price = 0.01 ether;

    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // maxTokenIds defines the maximum number of NFTs
    uint256 public maxTokenIds = 20;

    // total number of NFTs minted
    uint256 public tokenIds;

    // Allowlist contract instance
    IAllowlist allowlist;

    // Tracks if the presale has started
    bool public presaleStarted;

    // Tracks if the presale has ended
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    /**
     * @dev ERC721 constructor takes in a `name` and a `symbol` to the token
     * collection. name in our case is `Crypto Devs` and symbol is `CD`.
     * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI
     * for the collection. It also initializes an instance of whitelist
     * interface.
     */
    constructor(string memory baseURI, address allowlistContract)
        ERC721("Crypto Devs", "CD")
    {
        _baseTokenURI = baseURI;
        allowlist = IAllowlist(allowlistContract);
    }

    /**
     * @dev startPresale starts a presale for the whitelisted addresses
     */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        // Set presaleEnded time as current timestamp + 5 minutes
        presaleEnded = block.timestamp + 5 minutes;
    }

    /**
     * @dev presaleMint allows a user to mint one NFT per transaction during the
     * presale.
     */
    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "Presale has finished"
        );
        require(
            allowlist.whitelistedAddresses(msg.sender),
            "You are not in the allowlist"
        );
        require(tokenIds < maxTokenIds, "Exceeded maximum NFTs supply");
        require(msg.value >= _price, "Ether sent is less than the NFT price");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev mint allows a user to mint 1 NFT per transaction after the presale
     * has ended.
     */
    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp >= presaleEnded,
            "Presale has not ended yet"
        );
        require(tokenIds < maxTokenIds, "Maximum numbe of NFTs reached");
        require(msg.value >= _price, "Ether sent is less than the NFT price");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by
     * default
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
     * @dev withdraw sends all the ether in the contract to the owner of the
     * contract
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is callable when msg.data is not empty
    fallback() external payable {}
}
