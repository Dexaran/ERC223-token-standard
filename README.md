## Implementation.

### Current implementation

This repo's contracts are separated in 3 parts:

- [Interface](https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_interface.sol): The standard itself. The minimal common API ERC223 tokens and receivers to interact with each other.
- [Proposed implementations](https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_token.sol): A first approach as to how this could be implemented.
- [Receiver interface](https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_receiving_contract.sol): A dummy receiver that is intended to accept ERC223 tokens.

### Minimal viable implementation of the token, ready for use.

https://github.com/Dexaran/ERC223Token

## ERC223 token standard.

ERC20 token standard suffers [critical problems](https://medium.com/@dexaran820/erc20-token-standard-critical-problems-3c10fd48657b), that caused loss of approximately $3,000,000 at the moment (31 Dec, 2017). The main and the most important is lack of event handling mechanism of ERC20 standard.

ERC223 is a superset of the [ERC20](https://github.com/ethereum/EIPs/issues/20) token standard. It is a step forward towards economic abstraction at the application/contract level allowing the use of tokens as first class value transfer assets in smart contract development. It is also a more safe standard as it doesn't allow token transfers to contracts that don't support token receiving and handling.

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
            receiver.tokenFallback(msg.sender, _value, _data);
        }
    }
}
```

### API

ERC223 requires contract to implement the `ERC223Receiver` interface in order to receive tokens. If a user tries to send ERC223 tokens to a non-receiver contract the function will throw in the same way that it would if you sent ether to a contract without the called function being `payable`.

An example of the high-level API for a receiver contract is:

```solidity
contract ExampleReceiver is StandardReceiver {
  function foo() tokenPayable {
    LogTokenPayable(tkn.addr, tkn.sender, tkn.value);
  }

  function () tokenPayable {
    LogTokenPayable(tkn.addr, tkn.sender, tkn.value);
  }

  event LogTokenPayable(address token, address sender, uint value);
}
```

Where functions that have the `tokenPayable` can only be called via a token fallback and inside the functions you have access to the `tkn` struct that tries to mimic the `msg` struct used for ether calls.

The function `foo()` will be called when a user transfers ERC223 tokens to the receiver address.

```solidity
  // 0xc2985578 is the identifier for function foo. Sending it in the data parameter of a tx will result in the function being called.

  erc223.transfer(receiverAddress, 10, 0xc2985578)
```

What happens under the hood is that the ERC223 token will detect it is sending tokens to a contract address, and after setting the correct balances it will call the `tokenFallback` function on the receiver with the specified data. `StandardReceiver` will set the correct values for the `tkn` variables and then perform a `delegatecall` to itself with the specified data, this will result in the call to the desired function in the contract.

The current `tkn` values are:

- `tkn.sender` the original `msg.sender` to the token contract, the address originating the token transfer.
  - For user originated transfers sender will be equal to `tx.origin`
  - For contract originated transfers, `tx.origin` will be the user that made the transaction to that contract.

- `tkn.origin` the origin address from whose balance the tokens are sent
  - For `transfer()`, it will be the same as `tkn.sender`
  - For `transferFrom()`, it will be the address that created the allowance in the token contract

- `tkn.value` the amount of tokens sent
- `tkn.data` arbitrary data sent with the token transfer. Simulates ether `tx.data`.
- `tkn.sig` the first 4 bytes of `tx.data` that determine what function is called.

### The main goals of developing ERC223 token standard were:
  1. Accidentally lost tokens inside contracts: there are two different ways to transfer ERC20 tokens depending on is the receiver address a contract or a wallet address. You should call `transfer` to send tokens to a wallet address or call `approve` on token contract then `transferFrom` on receiver contract to send tokens to contract. Accidentally call of `transfer` function to a contract address will cause a loss of tokens inside receiver contract.
  2. Inability of handling incoming token transactions: ERC20 token transaction is a call of `transfer` function inside token contract. ERC20 token contract is not notifying receiver that transaction occurs. Also there is no way to handle incoming token transactions on contract and no way to reject any non-supported tokens.
  3. ERC20 token transaction between wallet address and contract is a couple of two different transactions in fact: You should call `approve` on token contract and then call `transferFrom` on another contract when you want to deposit your tokens intor it.
  4. Ether transactions and token transactions behave different: one of the goals of developing ERC223 was to make token transactions similar to Ether transactions to avoid users mistakes when transferring tokens and make interaction with token transactions easier for contract developers.

### ERC223 advantages.
  1. Provides a possibility to avoid accidentally lost tokens inside contracts that are not designed to work with sent tokens.
  2. Allows users to send their tokens anywhere with one function `transfer`. No difference between is the receiver a contract or not. No need to learn how token contract is working for regular user to send tokens.
  3. Allows contract developers to handle incoming token transactions.
  4. ERC223 `transfer` to contract consumes 2 times less gas than ERC20 `approve` and `transferFrom` at receiver contract.
  5. Allows to deposit tokens intor contract with a single transaction. Prevents extra blockchain bloating.
  6. Makes token transactions similar to Ether transactions.

  ERC223 tokens are backwards compatible with ERC20 tokens. It means that ERC223 supports every ERC20 functional and contracts or services working with ERC20 tokens will work with ERC223 tokens correctly.
ERC223 tokens should be sent by calling `transfer` function on token contract with no difference is receiver a contract or a wallet address. If the receiver is a wallet ERC223 token transfer will be same to ERC20 transfer. If the receiver is a contract ERC223 token contract will try to call `tokenFallback` function on receiver contract. If there is no `tokenFallback` function on receiver contract transaction will fail. `tokenFallback` function is analogue of `fallback` function for Ether transactions. It can be used to handle incoming transactions. There is a way to attach `bytes _data` to token transaction similar to `_data` attached to Ether transactions. It will pass through token contract and will be handled by `tokenFallback` function on receiver contract. There is also a way to call `transfer` function on ERC223 token contract with no data argument or using ERC20 ABI with no data on `transfer` function. In this case `_data` will be empty bytes array.

### The reason of designing ERC223 token standard.
Here is a description of the ERC20 token standard problem that is solved by ERC223:

ERC20 token standard is leading to money losses for end users. The main problem is lack of possibility to handle incoming ERC20 transactions, that were performed via `transfer` function of ERC20 token.

If you send 100 ETH to a contract that is not intended to work with Ether, then it will reject a transaction and nothing bad will happen. If you will send 100 ERC20 tokens to a contract that is not intended to work with ERC20 tokens, then it will not reject tokens because it cant recognize an incoming transaction. As the result, your tokens will get stuck at the contracts balance.

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

Another disadvantages of ERC20 that ERC223 will solve: 
1. Lack of `transfer` handling possibility.
2. Loss of tokens.
3. Token-transactions should match Ethereum ideology of uniformity. When a user wants to transfer tokens, he should always call `transfer`. It doesn't matter if the user is depositing to a contract or sending to an externally owned account.

Those will allow contracts to handle incoming token transactions and prevent accidentally sent tokens from being accepted by contracts (and stuck at contract's balance).

For example decentralized exchange will no more need to require users to call `approve` then call `deposit` (which is internally calling `transferFrom` to withdraw approved tokens). Token transaction will automatically be handled at the exchange contract.

The most important here is a call of `tokenFallback` when performing a transaction to a contract.

ERC223 EIP https://github.com/ethereum/EIPs/issues/223
ERC20 EIP https://github.com/ethereum/EIPs/issues/20
