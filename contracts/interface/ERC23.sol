pragma solidity ^0.4.8;

 /*
  ERC23 additions to ERC20

  Interface wise is ERC20 + data paramenter to transfer and transferFrom.
 */

import "zeppelin/token/ERC20.sol";

contract ERC23 is ERC20 {
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint value, bytes data) returns (bool ok);
}
