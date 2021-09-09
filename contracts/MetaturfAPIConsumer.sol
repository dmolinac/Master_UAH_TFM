// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;
 
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
 
contract MetaturfAPIConsumer is ChainlinkClient {
  
  //using strings for *;
  
    string public winnerRawText;
    
    string lastRacesRequest;
    string raceWinnerRequest;
 
    struct Horse {
        uint horseid; // Puede ser la key del mapping
        string name;
        address owner;
        uint wins;
    }
 
    struct Race {
        uint raceid; //Puede ser la key del mapping
        string racecourse;
        string date;
        string time;
        Horse winner;
    }
 
    mapping (uint => Race) races;
    mapping (uint => Horse) horses;
    
    address private oracle;
    bytes32 private jobId_getLastRaces;
    bytes32 private jobId_getRaceWinner;
 
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Chainlink - 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e
     * Chainlink - 29fa9aa13bf1468788b7cc4a500a45b8
     * Fee: 0.1 LINK
     */
    constructor() public {
        setPublicChainlinkToken();
        oracle = 0x9dD3298DAd96648E7fdF5632b9813D22Bbb3eb61;
        jobId_getLastRaces = "b4b92e3799054662b2a62fde1d63b123";  //TODO
        jobId_getRaceWinner = "9daa7f5130ab4439a63dee42a15d119a"; //Correcto
        fee = 1 * 10 ** 18; // 1 LINK
        
        lastRacesRequest = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=listraces&id=1&date=20210619&format=json";
        raceWinnerRequest = "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=getwinner&id=";
 
    }
    
    function requestRaceWinner(uint raceid) public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId_getRaceWinner, address(this), this.fulfillRaceWinner.selector);
       
       //Para declarar variables de tipo string dentro de funciones
       //string memory mystring = "foo2";
       string memory rid = uintToString(raceid);
       string memory format = "&format=json";
       
        // Set the URL to perform the GET request on
        //request.add("get", "https://ghdbadmin.metaturf.com/rest/rest_web3.php?resource=getwinner&id=7178&format=json");
        string memory requestb = string(abi.encodePacked(raceWinnerRequest, rid, format));
        request.add("get", requestb);
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {"code":1,
        //   "status":200,
        //   "data":{
        //     "horseinfo":"13882,GALILODGE (FR),1"
        //    }
        // }
 
        request.add("path", "data.horseinfo");
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of bytes32
     */ 
    function fulfillRaceWinner(bytes32 _requestId, bytes32 _winner) public recordChainlinkFulfillment(_requestId) {
        winnerRawText = bytes32ToString(_winner);
        /*
        var s = winnerRawText.toSlice();
        var delim = ",".toSlice();
        var parts = new string[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        
        //TODO: Investigar como hacer bien las asignaciones del mapping
        races[part[0]].winner.horseid = part[1];
        horses[part[1]].name = part[2];
        horses[part[1]].wins = part[3];
        */
        return;
    }
    
    
    /**
     * Withdraw LINK from this contract
     * 
     * NOTE: DO NOT USE THIS IN PRODUCTION AS IT CAN BE CALLED BY ANY ADDRESS.
     * THIS IS PURELY FOR EXAMPLE PURPOSES ONLY.
     */
    function withdrawLink() external {
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))), "Unable to transfer");
    }
    
    //////////////////////
    // HELPER FUNCTIONS //
    //////////////////////
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    //https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }
    
    //https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
    function appendUintToString(string memory inStr, uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        return string(s);
    }
   
    //https://ethereum.stackexchange.com/questions/10932/how-to-convert-string-to-int 
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        return result; // this was missing
    }
}
