pragma solidity ^0.4.9;

/* New ERC23 contract interface */

contract ERC23 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


 /*
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
contract ERC23Token is ERC23 {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

// A function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint _value) returns (bool success) {
     //filtering if the target is a contract with bytecode inside it
    if(isContract(_to))
    {
        transferToContract(_to, _value);
    }
    else
    {
        transferToAddress(_to, _value);
    }
    return true;
  }

//function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
//function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    contractReciever reciever = contractReciever(_to);
    reciever.fallbackToken(msg.sender, _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            // retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        if(length>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}
