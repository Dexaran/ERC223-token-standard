pragma solidity ^0.4.9;

 /*
 * Contract that is working with ERC23 tokens
 * it will take only specified tokents and prevent accident token transfers from another ERC23 contracts
 * like every contract is throwing accident ether transactions
 */
 
 contract contractReciever {
     
    //supported token contracts are stored here
    mapping (address => bool) supportedTokens;
    
    //contract creator can add supported tokens
    function addToken(address _token){     //onlyOwner
        supportedTokens[_token]=true;
    }
    
    //if token is now disabled, replacced or not supported for other reasons we it can be disabled
    function removeToken(address _token){  //onlyOwner
        supportedTokens[_token]=false;
    }
    
    //Fallback fuction analogue called from token contract when token transaction to this contract appears
    function fallbackToken(address _from, uint _value){
    
        if(supportedTokens[msg.sender])
        {
            //on token transfer handler code here
        }
        //throw any accident transfers of not supported tokens
        else{ throw; }
    }
 }