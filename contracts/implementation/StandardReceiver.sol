pragma solidity ^0.4.8;

 /* ERC23 additions to ERC20 */

import "../interface/ERC23Receiver.sol";

contract StandardReceiver is ERC23Receiver {

//We don't need to declare TKN object here.

  struct Tkn {
    address addr;
    address sender;
    address origin;
    uint256 value;
    bytes data;
    bytes4 sig;
  }

  function tokenFallback(address _sender, address _origin, uint _value, bytes _data) returns (bool ok) {
    //Just declare it here in a local function to make it safe accessing .tkn values
    TKN tkn;
    
    if (!supportsToken(msg.sender)) return false;
    tkn = Tkn(msg.sender, _sender, _origin, _value, _data, getSig(_data));
    if (!address(this).delegatecall(_data)) return false;

    // avoid doing an overwrite to .token, which would be more expensive
    delete tkn;

    return true;
  }

  function getSig(bytes _data) private returns (bytes4 sig) {
    uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
    bytes4 sig = bytes4(u);
  }

  bool __isTokenFallback;

  modifier tokenPayable {
    if (!__isTokenFallback) throw;
    _;
  }

  function supportsToken(address token) returns (bool);
}
