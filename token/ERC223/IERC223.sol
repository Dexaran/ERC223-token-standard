    
pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * [ERC1820 registry standard](https://eips.ethereum.org/EIPS/eip-1820) to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See `IERC1820Registry` and
 * `ERC1820Implementer`.
 */

contract IERC223 {
    /**
     * @dev Returns the total supply of the token.
     */
    uint public totalSupply;
    
    /**
     * @dev Returns the balance of the `who` address.
     */
    function balanceOf(address who) public view returns (uint);
        
    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address
     * and returns `true` on success.
     */
    function transfer(address to, uint value) public returns (bool success);
        
    /**
     * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
     * and returns `true` on success.
     */
    function transfer(address to, uint value, bytes memory data) public returns (bool success)
     
     /**
     * @dev Event that is fired on successful transfer.
     */
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
