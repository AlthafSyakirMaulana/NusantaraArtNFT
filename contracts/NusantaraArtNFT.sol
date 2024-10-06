// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NusantaraArtNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Artwork {
        string name;
        string description;
        string imageURI;
        uint256 price;
        address artist;
        string region;
    }

    mapping(uint256 => Artwork) public artworks;

    event ArtworkMinted(uint256 indexed tokenId, address indexed artist, string name, uint256 price, string region);
    event ArtworkSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);

    constructor() ERC721("NusantaraArtNFT", "NANT") {}

    function mintArtwork(string memory name, string memory description, string memory imageURI, uint256 price, string memory region) public {
        require(price > 0, "Price must be greater than zero");  // Validasi harga

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        artworks[newTokenId] = Artwork(name, description, imageURI, price, msg.sender, region);

        emit ArtworkMinted(newTokenId, msg.sender, name, price, region);
    }

    function buyArtwork(uint256 tokenId) public payable {
        require(_exists(tokenId), "Token does not exist");
        require(msg.value >= artworks[tokenId].price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "You already own this artwork");

        _transfer(seller, msg.sender, tokenId);

        // Menggunakan call untuk transfer ether yang lebih aman
        (bool success, ) = seller.call{value: msg.value}("");
        require(success, "Transfer failed.");

        emit ArtworkSold(tokenId, seller, msg.sender, msg.value);
    }

    function getArtwork(uint256 tokenId) public view returns (Artwork memory) {
        require(_exists(tokenId), "Token does not exist");
        return artworks[tokenId];
    }

    function updateArtworkPrice(uint256 tokenId, uint256 newPrice) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this artwork");
        require(newPrice > 0, "Price must be greater than zero");  // Validasi harga baru
        artworks[tokenId].price = newPrice;
    }

    function getArtistArtworks(address artist) public view returns (uint256[] memory) {
        uint256 totalSupply = _tokenIds.current();
        uint256[] memory result = new uint256[](totalSupply);
        uint256 counter = 0;

        for (uint256 i = 1; i <= totalSupply; i++) {
            if (artworks[i].artist == artist) {
                result[counter] = i;
                counter++;
            }
        }

        uint256[] memory artistArtworks = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            artistArtworks[i] = result[i];
        }

        return artistArtworks;
    }
}
