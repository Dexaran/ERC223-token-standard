pragma solidity ^0.4.9;

 /*
 * Contract that is working with ERC23 tokens
 * it will take only specified tokents and prevent accident token transfers from another ERC23 contracts
 * like every contract is throwing accident ether transactions
 */
 
 contract ContractReceiver {
    function tokenFallback(address _from, uint _value, bytes _data){
      //Incoming transaction code here
    }
}
