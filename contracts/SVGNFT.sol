//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";

contract SVGNFT is ERC721URIStorage {
    uint256 public tokenCounter;

    event CreatedSVGNFT(uint256 indexed tokenId, string tokenURI);

    constructor() ERC721("SVG NFT", "svgNFT") {
        tokenCounter = 0;
    }

    function create(string memory _svg) public {
        string memory imageURI = svgToImageURI(_svg);
        string memory tokenURI = formatTokenURI(imageURI);
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenURI);
        emit CreatedSVGNFT(tokenCounter, tokenURI);
        tokenCounter++;
    } 

    function svgToImageURI(string memory _svg) public pure returns(string memory) {
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(string(abi.encodePacked(_svg))))));
    }

    function formatTokenURI(string memory _imageURI) public pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(
                abi.encodePacked(' {"name":"SVG NFT", "description": "SVG based NFT!", "attributes": "", "image": "', _imageURI, '"}')
            ))
        ));
    }
}