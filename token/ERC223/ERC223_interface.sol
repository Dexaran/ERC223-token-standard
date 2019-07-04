pragma solidity ^0.5.0;

contract ERC223Interface {
    uint public totalSupply;
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool success);
    function transfer(address to, uint value, bytes memory data) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
