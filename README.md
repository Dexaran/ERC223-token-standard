# ERC23 [![Build Status](https://img.shields.io/travis/AragonOne/ERC23.svg?branch=master&style=flat-square)](https://travis-ci.org/AragonOne/ERC23)

ERC23 is a superset of the [ERC20](https://github.com/ethereum/EIPs/issues/20) token standard. It is a step forward towards economic abstraction at the application/contract level allowing the use of tokens as first class value transfer assets in smart contract development. It is also a more safe standard as it doesn't allow token transfers to contracts that don't support token receiving and handling.

[See EIP discussion](https://github.com/ethereum/EIPs/issues/223)

```solidity
// interfaces/ERC23.sol

contract ERC23 is ERC20 {
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint value, bytes data) returns (bool ok);
}
```

### API

ERC23 requires contract to implement the `ERC23Receiver` interface in order to receive tokens. If a user tries to send ERC23 tokens to a non-receiver contract the function will throw in the same way that it would if you sent ether to a contract without the called function being `payable`.

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

The function `foo()` will be called when a user transfers ERC23 tokens to the receiver address.

```solidity
  // 0xc2985578 is the identifier for function foo. Sending it in the data parameter of a tx will result in the function being called.

  erc23.transfer(receiverAddress, 10, 0xc2985578)
```

What happens under the hood is that the ERC23 token will detect it is sending tokens to a contract address, and after setting the correct balances it will call the `tokenFallback` function on the receiver with the specified data. `StandardReceiver` will set the correct values for the `tkn` variables and then perform a `delegatecall` to itself with the specified data, this will result in the call to the desired function in the contract.

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

### Current implementation

This repo's contracts are separated in 3 parts:

- [Interfaces](/contracts/interface): The standard itself. The minimal common API ERC23 tokens and receivers to interact with each other.
- [Proposed implementations](/contracts/implementation): A first approach as to how this could be implemented. In case of the [token](/contracts/implementation/Standard23Token.sol), it is built on top of heavily tested and used [Zeppelin's](http://openzeppelin.org) Standard Token, and then adds the specific ERC23 features on top. The [receiver](/contracts/implementation/StandardReceiver.sol) implementation is kept at the bare minimum for setting the `tkn` values and dispatching the call to the correct function.
- [Examples](/contracts/example): A dummy token and receiver to see the API in action.

### The main goals of developing ERC23 token standard were:
  1. Accidentally lost tokens inside contracts: there are two different ways to transfer ERC20 tokens depending on is the receiver address a contract or a wallet address. You should call `transfer` to send tokens to a wallet address or call `approve` on token contract then `transferFrom` on receiver contract to send tokens to contract. Accidentally call of `transfer` function to a contract address will cause a loss of tokens inside receiver contract where tokens will never be accessibe.
  2. Inability of handling incoming token transactions: ERC20 token transaction is a call of `transfer` function inside token contract. ERC20 token contract is not notifying receiver that transaction occurs. Also there is no way to handle incoming token transactions on contract and no way to reject any non-supported tokens.
  3. ERC20 token transaction between wallet address and contract is a couple of two different transactions in fact: You should call `approve` on token contract and then call `transferFrom` on another contract when you want to deposit your tokens intor it.
  4. Ether transactions and token transactions behave different: one of the goals of developing ERC23 was to make token transactions similar to Ether transactions to avoid users mistakes when transferring tokens and make interaction with token transactions easier for contract developers.

### ERC23 advantages.
  1. Provides a possibility to avoid accidentally lost tokens inside contracts that are not designed to work with sent tokens.
  2. Allows users to send their tokens anywhere with one function `transfer`. No difference between is the receiver a contract or not. No need to learn how token contract is working for regular user to send tokens.
  3. Allows contract developers to handle incoming token transactions.
  4. ERC23 `transfer` to contract consumes 2 times less gas than ERC20 `approve` and `transferFrom` at receiver contract.
  5. Allows to deposit tokens intor contract with a single transaction. Prevents extra blockchain bloating.
  6. Makes token transactions similar to Ether transactions.

  ERC23 tokens are backwards compatible with ERC20 tokens. It means that ERC23 supports every ERC20 functional and contracts or services working with ERC20 tokens will work with ERC23 tokens correctly.
ERC23 tokens should be sent by calling `transfer` function on token contract with no difference is receiver a contract or a wallet address. If the receiver is a wallet ERC23 token transfer will be same to ERC20 transfer. If the receiver is a contract ERC23 token contract will try to call `tokenFallback` function on receiver contract. If there is no `tokenFallback` function on receiver contract transaction will fail. `tokenFallback` function is analogue of `fallback` function for Ether transactions. It can be used to handle incoming transactions. There is a way to attach `bytes _data` to token transaction similar to `_data` attached to Ether transactions. It will pass through token contract and will be handled by `tokenFallback` function on receiver contract. There is also a way to call `transfer` function on ERC23 token contract with no data argument or using ERC20 ABI with no data on `transfer` function. In this case `_data` will be empty bytes array.

ERC23 EIP https://github.com/ethereum/EIPs/issues/223
ERC20 EIP https://github.com/ethereum/EIPs/issues/20

 ### Lost tokens held by contracts
There is already a number of tokens held by token contracts themselves. This tokens will not be accessible as there is no function to withdraw them from contract.

43071 GNT in Golem contract ~ $1000:
https://etherscan.io/token/Golem?a=0xa74476443119a942de498590fe1f2454d7d4ac0d

103 REP in Augur contract ~ $600:
https://etherscan.io/token/REP?a=0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5

777 DGD in Digix DAO contract ~ $7500:
https://etherscan.io/token/0xe0b7927c4af23765cb51314a0e0521a9645f0e2a?a=0xe0b7927c4af23765cb51314a0e0521a9645f0e2a

10100  1ST in FirstBlood contract ~ $883:
https://etherscan.io/token/FirstBlood?a=0xaf30d2a7e90d7dc361c8c4585e9bb7d2f6f15bc7
