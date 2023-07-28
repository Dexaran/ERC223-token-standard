### EIP-223

Read the original discussion and formal description here: https://github.com/ethereum/eips/issues/223

### Current implementation

Main ERC-223 contracts:

- [IERC223.sol](https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223.sol): Token interface. The minimal common API ERC-223 tokens and receivers must implement in order to interact with each other.
- [ERC223.sol](https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/ERC223.sol): Token contract. Defines logic of the basic ERC-223 token. This functionality can be extended with additional functions (such as `burn()`, `mint()`, ownership or `approve / transferFrom` pattern of ERC20).
- [Recipient interface](https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/IERC223Recipient.sol): A dummy receiver that is intended to accept ERC-223 tokens. Use `contract MyContract is IERC223Recipient` to make contract capable of accepting ERC-223 token transactions. Contract that does not support IERC223Recipient interface can receive tokens if this contract implements a permissive fallback function (this method of token receiving is not recommended). If a contract does not implement IERC223Recipient `tokenReceived` function and does not implement a permissive fallback function then this contract can not receive ERC-223 tokens.

### Extensions of the base functionality

- [ERC223Mintable.sol](https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/extensions/ERC223Mintable.sol): Minting functinality for ERC223 tokens.

- [ERC223Burnable.sol](https://github.com/Dexaran/ERC223-token-standard/blob/development/token/ERC223/extensions/ERC223Burnable.sol): Burning functionality implementation for ERC223 tokens. Allows any address to burn its tokens by calling the `burn` function of the contract.

## ERC223 token standard.

ERC-20 token standard suffers [critical problems](https://medium.com/@dexaran820/erc20-token-standard-critical-problems-3c10fd48657b), that caused loss of approximately $3,000,000 at the moment (31 Dec, 2017). The main and the most important problem is the lack of event handling mechanism in ERC20 standard.

ERC-223 is a superset of the [ERC20](https://github.com/ethereum/EIPs/issues/20). It is a step forward towards economic abstraction at the application/contract level allowing the use of tokens as first class value transfer assets in smart contract development. It is also a more secure standard as it doesn't allow token transfers to contracts that do not explicitly support token receiving.

[See EIP discussion](https://github.com/ethereum/EIPs/issues/223)

```js
contract ERC223 {
  function transfer(address to, uint value, bytes data) {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            // Require proper transaction handling.
            ERC223Receiver receiver = ERC223Receiver(_to);
            receiver.tokenReceived(msg.sender, _value, _data);
        }
    }
}
```

### The main problems of ERC-20 that ERC-223 solves

  1. **Lost tokens**: there are two different ways to transfer ERC20 tokens depending on is the receiver address a contract or a wallet address. You should call `transfer` to send tokens to a wallet address or call `approve` on token contract then `transferFrom` on receiver contract to send tokens to contract. Accidentally call of `transfer` function to a contract address will cause a loss of tokens inside receiver contract.
  2. **Impossibility of handling incoming token transactions / lack of event handling in ERC20**: ERC20 token transaction is a call of `transfer` function inside token contract. ERC20 token contract is not notifying receiver that transaction occurs. Also there is no way to handle incoming token transactions on contract and no way to reject any non-supported tokens.
  3. **Optimization of ERC20 address-to-contract communication**: You should call `approve` on token contract and then call `transferFrom` on another contract when you want to deposit your tokens into it. In fact address-to-contract transfer is a couple of two different transactions in ERC20. It also costs twice more gas compared to ERC223 transfers. In ERC223 address-to-contract transfer is a single transaction just like address-to-address transfer.
  4. **Ether transactions and token transactions behave differently**: one of the goals of developing ERC223 was to make token transactions similar to Ether transactions to avoid users mistakes when transferring tokens and make interaction with token transactions easier for contract developers.

### ERC-223 advantages.

  1. Provides a possibility to avoid accidentally lost tokens inside contracts that are not designed to work with sent tokens.
  2. Allows users to send their tokens anywhere with one function `transfer`. No difference between is the receiver a contract or not. No need to learn how token contract is working for regular user to send tokens.
  3. Allows contract developers to handle incoming token transactions.
  4. ERC223 `transfer` to contract consumes 2 times less gas than ERC20 `approve` and `transferFrom` at receiver contract.
  5. Allows to deposit tokens into contract with a single transaction. Prevents extra blockchain bloating.
  6. Makes token transactions similar to Ether transactions.

  ERC-223 tokens are backwards compatible with ERC-20 tokens. It means that ERC-223 supports every ERC-20 functional and contracts or services working with ERC-20 tokens will work with ERC-223 tokens correctly.
ERC-223 tokens should be sent by calling `transfer` function on token contract with no difference is receiver a contract or a wallet address. If the receiver is a wallet ERC-223 token transfer will be same to ERC-20 transfer. If the receiver is a contract ERC-223 token contract will try to call `tokenReceived` function on receiver contract. If there is no `tokenReceived` function on receiver contract transaction will fail. `tokenReceived` function is analogue of `fallback` function for Ether transactions. It can be used to handle incoming transactions. There is a way to attach `bytes _data` to token transaction similar to `_data` attached to Ether transactions. It will pass through token contract and will be handled by `tokenReceived` function on receiver contract. There is also a way to call `transfer` function on ERC-223 token contract with no data argument or using ERC-20 ABI with no data on `transfer` function. In this case `_data` will be empty bytes array.

### The reason of designing ERC-223 token standard.
Here is a description of the ERC-20 token standard problem that is solved by ERC-223:

ERC-20 token standard is leading to money losses for end users. The main problem is lack of possibility to handle incoming ERC-20 transactions, that were performed via `transfer` function of ERC-20 token.

If you send 100 ETH to a contract that is not intended to work with Ether, then it will reject a transaction and nothing bad will happen. If you will send 100 ERC-20 tokens to a contract that is not intended to work with ERC-20 tokens, then it will not reject tokens because it cant recognize an incoming transaction. As the result, your tokens will get stuck at the contracts balance.

How much ERC20 tokens are currently lost (31 Dec, 2017):

1. QTUM, **$1,358,441** lost. [watch on Etherscan](https://etherscan.io/address/0x9a642d6b3368ddc662CA244bAdf32cDA716005BC)

2. EOS, **$1,015,131** lost. [watch on Etherscan](https://etherscan.io/address/0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0)

3. GNT, **$249,627** lost. [watch on Etherscan](https://etherscan.io/address/0xa74476443119A942dE498590Fe1f2454d7D4aC0d)

4. STORJ, **$217,477** lost. [watch on Etherscan](https://etherscan.io/address/0xe41d2489571d322189246dafa5ebde1f4699f498)

5. Tronix , **$201,232** lost. [watch on Etherscan](https://etherscan.io/address/0xf230b790e05390fc8295f4d3f60332c93bed42e2)

6. DGD, **$151,826** lost. [watch on Etherscan](https://etherscan.io/address/0xe0b7927c4af23765cb51314a0e0521a9645f0e2a)

7. OMG, **$149,941** lost. [watch on Etherscan](https://etherscan.io/address/0xd26114cd6ee289accf82350c8d8487fedb8a0c07)

8. STORJ, **$102,560** lost. [watch on Etherscan](https://etherscan.io/address/0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac)

9. MANA, **$101,967** lost. [watch on Etherscan](https://etherscan.io/address/0x0f5d2fb29fb7d3cfee444a200298f468908cc942)

Another disadvantages of ERC-20 that ERC-223 solves: 
1. Lack of `transfer` handling possibility.
2. Loss of tokens.
3. Token-transactions should match Ethereum ideology of uniformity. When a user wants to transfer tokens, he should always call `transfer`. It doesn't matter if the user is depositing to a contract or sending to an externally owned account.

Those will allow contracts to handle incoming token transactions and prevent accidentally sent tokens from being accepted by contracts (and stuck at contract's balance).

For example decentralized exchange will no more need to require users to call `approve` then call `deposit` (which is internally calling `transferFrom` to withdraw approved tokens). Token transaction will automatically be handled at the exchange contract.

The most important here is a call of `tokenReceived` when performing a transaction to a contract.

ERC20 EIP https://github.com/ethereum/EIPs/issues/20
