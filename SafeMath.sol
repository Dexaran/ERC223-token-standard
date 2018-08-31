pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(unit256 a, unit256 b) internal returns (uint) {
    unit256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(unit256 a, unit256 b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    unit256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(unit256 a, unit256 b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(unit256 a, unit256 b) internal returns (uint) {
    unit256 c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
