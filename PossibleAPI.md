

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

What happens under the hood is that the ERC223 token will detect it is sending tokens to a contract address, and after setting the correct balances it will call the `tokenReceived` function on the receiver with the specified data. `StandardReceiver` will set the correct values for the `tkn` variables and then perform a `delegatecall` to itself with the specified data, this will result in the call to the desired function in the contract.

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
