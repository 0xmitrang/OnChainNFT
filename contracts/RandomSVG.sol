//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "base64-sol/base64.sol";


contract RandomSVG is ERC721URIStorage, VRFConsumerBase {

    bytes32 public keyHash;
    uint256 public fee;
    uint256 public tokenCounter;
    uint256 public maxNumberOfPaths;
    uint256 public maxNumberOfPathCommands;
    uint256 public size;
    string[] public pathCommands;
    string[] public colors;

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;

    event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId);
    event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 randomNumber);
    event CreatedRandomSVG(uint256 indexed tokenId, string tokenURI);

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyHash, uint256 _fee) 
        ERC721("RandomSVG", "rsNFT")
        VRFConsumerBase(_VRFCoordinator, _LinkToken) {
            keyHash = _keyHash;
            fee = _fee;
            tokenCounter = 0;
            maxNumberOfPaths = 10;
            maxNumberOfPathCommands = 5;
            size = 500;
            pathCommands = ["M", "L"];
            colors = ["red", "blue", "green", "yellow", "black", "white"];
    }

    function create() public returns (bytes32 _requestId) {
        _requestId = requestRandomness(keyHash, fee);
        requestIdToSender[_requestId] = msg.sender;
        uint256 tokenId = tokenCounter;
        requestIdToTokenId[_requestId] = tokenId;
        tokenCounter += 1;
        emit requestedRandomSVG(_requestId, tokenId);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal override {
        uint256 tokenId = requestIdToTokenId[_requestId];
        _safeMint(requestIdToSender[_requestId], tokenId);
        tokenIdToRandomNumber[tokenId] = _randomNumber;
        emit CreatedUnfinishedRandomSVG(tokenId, _randomNumber);
    }

    function finishMint(uint256 _tokenId) public {
        require(bytes(tokenURI(_tokenId)).length <= 0, "token URI is already set");
        require(tokenCounter > _tokenId, "Invalid TokenId");
        require(tokenIdToRandomNumber[_tokenId]>0, "Wait for ChainlinkVRF");

        uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
        string memory svg = generateSVG(randomNumber);
        string memory imageURI = svgToImageURI(svg);
        string memory tokenURI = formatTokenURI(imageURI);
        _setTokenURI(_tokenId, tokenURI);
        emit CreatedRandomSVG(_tokenId, svg);
    }

    //generateSVG from random number
    function generateSVG(uint256 _randomNumber) public view returns (string memory finalSvg) {
        uint256 numberOfPaths = (_randomNumber % maxNumberOfPaths) + 1;
        finalSvg = string(abi.encodePacked("<svg xmlns='http://www.w3.org/2000/svg' height='", uint2str(size), "' width='", uint2str(size), "'>"));
        for(uint i = 0; i < numberOfPaths; i++) {
            string memory pathSvg = generatePath(uint256(keccak256(abi.encode(_randomNumber, i))));
            finalSvg = string(abi.encodePacked(finalSvg, pathSvg));
        }
        finalSvg = string(abi.encodePacked(finalSvg, "</svg>"));
    }

    function generatePath(uint256 _randomNumber) public view returns(string memory pathSvg) {
        uint256 numberOfPathCommands = (_randomNumber % maxNumberOfPathCommands) + 1;
        pathSvg = "<path d='";
        for(uint i = 0; i<numberOfPathCommands; i++) {
            string memory pathCommand = generatePathCommand(uint256(keccak256(abi.encode(_randomNumber, size + i))));
            pathSvg = string(abi.encodePacked(pathSvg, pathCommand));
        }
        string memory color = colors[_randomNumber % colors.length];
        pathSvg = string(abi.encodePacked(pathSvg, "' fill='transparent' stroke='", color, "'/>"));
    }

    function generatePathCommand(uint256 _randomNumber) public view returns(string memory pathCommand) {
        pathCommand = pathCommands[_randomNumber % pathCommands.length];
        uint256 parameter1 = uint256(keccak256(abi.encode(_randomNumber, size * 2))) % size;
        uint256 parameter2 = uint256(keccak256(abi.encode(_randomNumber, size * 3))) % size;
        pathCommand = string(abi.encodePacked(pathCommand, " ", uint2str(parameter1), " ", uint2str(parameter2)));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    //svgToImageURI
    function svgToImageURI(string memory _svg) public pure returns(string memory) {
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(string(abi.encodePacked(_svg))))));
    }

    //formatTokenURI
    function formatTokenURI(string memory _imageURI) public pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(
                abi.encodePacked(' {"name":"SVG NFT", "description": "SVG based NFT!", "attributes": "", "image": "', _imageURI, '"}')
            ))
        ));
    }
}