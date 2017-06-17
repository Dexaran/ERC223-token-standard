pragma solidity ^0.4.11;

import './ERC223Basic.sol';
import './ERC223ReceivingContract.sol';
import '../../SafeMath.sol';

contract ERC223BasicToken is ERC223Basic{
    using SafeMath for uint;

    mapping(address => uint) balances;

    /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address to, uint value, bytes data) onlyPayloadSize(2 * 32) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        Transfer(msg.sender, to, value, data);
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address to, uint value) onlyPayloadSize(2 * 32) {
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            bytes memory empty;
            receiver.tokenFallback(msg.sender, value, empty);
        }
        Transfer(msg.sender, to, value);
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
}
