pragma solidity ^0.8.0;

import "https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223.sol";
import "https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223Recipient.sol";
import "https://github.com/Dexaran/ERC223-token-standard/blob/development/utils/Address.sol";
import "https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/ERC223.sol";

/**
 * @title Reference implementation of the ERC223 standard token with custom fallback invocations.
 */
abstract contract ERC223CustomFallbackToken is ERC223Token {
    
    event Response(bool _success, bytes _data);
    
    function transfer(address _to, uint _value, bytes calldata _data, string calldata _custom_fallback) public returns (bool success)
    {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            (bool _success, bytes memory _response) = address(_to).call(abi.encodeWithSignature(_custom_fallback, msg.sender, _value, _data));
            require(_success, "Fallback function execution failed on receivers side");
            
            emit Response(_success, _response);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
