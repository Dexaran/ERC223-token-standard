pragma solidity ^0.5.1;

import "./ERC223.sol";

/**
 * @dev Extension of {ERC223} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC223Burnable is ERC223Token {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 _amount) public {
        require(balanceOf(msg.sender) > _amount);
        
        bytes memory empty = hex"00000000";
        emit Transfer(msg.sender, address(0), _amount, empty);
    }
}
