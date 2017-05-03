pragma solidity ^0.4.9;
 
 /* New ERC23 contract interface */

contract ERC23 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}


 /**
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
contract ERC23Token is ERC23 {

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  
  
  //function to access name of token
  function name() constant returns (string _name) {
      return name;
  }
  //function to access symbol of token
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  //function to access decimals of token
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  
  

  //function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
  
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    uint codeLength;
    
    assembly {
        //retrieve the size of the code on target address, this needs assembly
        codeLength := extcodesize(_to)
    }
    
    if(codeLength>0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        ContractReceiver reciever = ContractReceiver(_to);
        reciever.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
    }
    else {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value, _data);
    }
    return true;
  }
  
  function transfer(address _to, uint _value) returns (bool success) {
      
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory emptyData;
    uint codeLength;
    
    assembly {
        //retrieve the size of the code on target address, this needs assembly
        codeLength := extcodesize(_to)
    }
    
    if(codeLength>0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        ContractReceiver reciever = ContractReceiver(_to);
        reciever.tokenFallback(msg.sender, _value, emptyData);
        Transfer(msg.sender, _to, _value, emptyData);
        return true;
    }
    else {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value, emptyData);
        return true;
    }
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}
