pragma solidity ^0.4.11;

contract ERC223Interface {
    unit256 public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, unit256 value);
    function transfer(address to, unit256 value, bytes data);
    event Transfer(address indexed from, address indexed to, unit256 value, bytes data);
}
