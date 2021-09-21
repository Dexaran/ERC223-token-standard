pragma solidity ^0.8.0;

import "./ERC223.sol";

/**
 * @dev Extension of {ERC223} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC223Mintable is ERC223Token {
    
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping (address => bool) public _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters[account] = true;
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters[account] = false;
        emit MinterRemoved(account);
    }
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        balances[account] = balances[account] + amount;
        _totalSupply = _totalSupply + amount;
        
        bytes memory empty = hex"00000000";
        emit Transfer(address(0),account, amount, empty);
        return true;
    }
}
