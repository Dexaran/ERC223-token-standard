pragma solidity ^0.5.0;

//import './ERC223_interface.sol';
//import './ERC223_receiving_contract.sol';
//import './SafeMath.sol';

/**
* imports for remix.ethereum.org
* see:
* https://solidity.readthedocs.io/en/latest/layout-of-source-files.html#use-in-actual-compilers
* https://remix.readthedocs.io/en/stable/tutorial_import.html#importing-from-github
*/
import "github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_interface.sol";
import "github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_receiving_contract.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract ERC223Token is ERC223Interface {

    using SafeMath for uint;

    mapping(address => uint) balances; // List of user balances.

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success){
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .

        uint codeLength;
        assembly {
        // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        emit Transfer(msg.sender, _to, _value, _data);

        return true;
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public returns (bool success){

        uint codeLength;
        bytes memory empty = hex"00000000";

        assembly {
        // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }

        emit Transfer(msg.sender, _to, _value, empty);

        return true;
    }

    /**
     * @dev Returns balance of the `_owner`.
     *
     * @param _owner   The address whose balance will be returned.
     * @return balance Balance of the `_owner`.
     */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

}
