//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;
/*

Create an ERC721 Token with the following requirements

user can only buy tokens when the sale is started
the sale should be ended within 30 days
the owner can set base URI
the owner can set the price of NFT
NFT minting hard limit is 100

*/
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract AXY721 is ERC721, Ownable{
    
    string public baseURI = "https://floydnft.com/token/";
    uint public salePrice;
    uint public hardLimit = 100;
    uint public currentPublicTokenID = 0;
    
    string _tokenName = "AXY Token";
    string _tokenSymbol = "AXY";
    uint public saleTill;
    
    using Strings for uint256;
    
    // mapping for storing token against uri
    mapping(uint=>string) public _tokenURImap;
    
    // constructor(string memory _tokenName, string memory _tokenSymbol,uint _salePrice) ERC721(_tokenName, _tokenSymbol){
    //     saleStart = false;
    //     salePrice = _salePrice;
    // }
    constructor() ERC721(_tokenName, _tokenSymbol){
        salePrice = 10;
        saleTill = 0 days;
    }
    
modifier _isSaleON() {
    require(block.timestamp < saleTill,"Sale is currently Off.");
    _;
}
    // ___________________ Starting the sale ________________________
  function startSale(uint _forDays) public onlyOwner{
      uint _Days = _forDays * 1 days;
      require(_Days <= 30 days,"The sale has to be less or equal to 30 days");
      saleTill = block.timestamp + _Days;
  }  
  // ___________________ Stoping the sale ________________________
  function stopSale() public onlyOwner{
      require(block.timestamp < saleTill,"Sale is already Off.");
      saleTill = 0 days;
  }  
  
  //_____________________ Buying NFT ________________________
  function mintNdIncrementSupply(address to, uint tokenID) internal{
         _mint(to,tokenID);
    }
    
    
  function mintAXY(address _to,uint _quantity) payable external _isSaleON {
        require(_to != address(0), "Can't mint to 0 address");
        require(msg.value >= salePrice * _quantity && currentPublicTokenID + _quantity <= 100, "Not Enough Ether to buy NFTs or The buying NFTs are more then 100");
        
        for(uint i = 1; i<= _quantity; i++){
            currentPublicTokenID++;
            mintNdIncrementSupply(_to, currentPublicTokenID);
            // ________ Binding an url to a token ____________
            _tokenURImap[currentPublicTokenID] = tokenURI(currentPublicTokenID);
        }
  }
  
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,tokenId.toString())) : "";
    }
  
  // ______________________ Setting URL _______________________
  function setURI(string memory _uri) public onlyOwner{
      baseURI = _uri;
    }
    
    // ______________________ Setting Price _______________________
  function setPrice(uint _price) public onlyOwner{
      salePrice = _price;
    }
}