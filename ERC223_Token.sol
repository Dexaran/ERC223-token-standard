pragma solidity ^0.4.9;

import "./Receiver_Interface.sol";
import "./ERC223_Interface.sol";

 /**
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
contract ERC223Token is ERC223 {

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  
  
  // Function to access name of token .
  function name() constant returns (string _name) {
      return name;
  }
  // Function to access symbol of token .
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  // Function to access decimals of token .
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  
  

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
  
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    uint codeLength;
    
    assembly {
        // Retrieve the size of the code on target address, this needs assembly .
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
  
  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address _to, uint _value) returns (bool success) {
      
    bytes memory _empty;
    uint codeLength;
    
    assembly {
        // Retrieve the size of the code on target address, this needs assembly .
        codeLength := extcodesize(_to)
    }
    
    if(codeLength>0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        ContractReceiver reciever = ContractReceiver(_to);
        reciever.tokenFallback(msg.sender, _value, _empty);
        Transfer(msg.sender, _to, _value, _empty);
    }
    else {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value, _empty);
    }
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
} 
