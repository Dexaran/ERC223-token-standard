# Proper simple token implementation.

https://github.com/Dexaran/ERC223Token

# ERC223 token standard.

Here is a description of the ERC20 token standard problem that is solved by ERC223:

ERC20 token standard is leading to money losses for end users. The main problem is lack of possibility to handle incoming ERC20 transactions, that were performed via `transfer` function of ERC20 token.

If you send 100 ETH to a contract that is not intended to work with Ether, then it will reject a transaction and nothing bad will happen. If you will send 100 ERC20 tokens to a contract that is not intended to work with ERC20 tokens, then it will not reject tokens because it cant recognize an incoming transaction. As the result, your tokens will get stuck at the contracts balance.

How much ERC20 tokens are currently lost (27 Dec, 2017):

1. QTUM, **$1,204,273** lost. [watch on Etherscan](https://etherscan.io/address/0x9a642d6b3368ddc662CA244bAdf32cDA716005BC)

2. EOS, **$1,015,131** lost. [watch on Etherscan](https://etherscan.io/address/0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0)

3. GNT, **$249,627** lost. [watch on Etherscan](https://etherscan.io/address/0xa74476443119A942dE498590Fe1f2454d7D4aC0d)

4. STORJ, **$217,477** lost. [watch on Etherscan](https://etherscan.io/address/0xe41d2489571d322189246dafa5ebde1f4699f498)

5. Tronix , **$201,232** lost. [watch on Etherscan](https://etherscan.io/address/0xf230b790e05390fc8295f4d3f60332c93bed42e2)

6. DGD, **$151,826** lost. [watch on Etherscan](https://etherscan.io/address/0xe0b7927c4af23765cb51314a0e0521a9645f0e2a)

7. OMG, **$149,941** lost. [watch on Etherscan](https://etherscan.io/address/0xd26114cd6ee289accf82350c8d8487fedb8a0c07)

8. STORJ, **$102,560** lost. [watch on Etherscan](https://etherscan.io/address/0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac)

NOTE: These are only 8 token contracts that I know. Each Ethereum contract is a potential token trap for ERC20 tokens, thus, there are much more losses than I showed at this example.

Another disadvantages of ERC20 that ERC223 will solve: 
1. Lack of `transfer` handling possibility.
2. Loss of tokens.
3. Token-transactions should match Ethereum ideology of uniformity. When a user wants to transfer tokens, he should always call `transfer`. It doesn't matter if the user is depositing to a contract or sending to an externally owned account.

Those will allow contracts to handle incoming token transactions and prevent accidentally sent tokens from being accepted by contracts (and stuck at contract's balance).

For example decentralized exchange will no more need to require users to call `approve` then call `deposit` (which is internally calling `transferFrom` to withdraw approved tokens). Token transaction will automatically be handled at the exchange contract.

The most important here is a call of `tokenFallback` when performing a transaction to a contract.

ERC223 EIP https://github.com/ethereum/EIPs/issues/223
ERC20 EIP https://github.com/ethereum/EIPs/issues/20

 ### Lost tokens held by contracts
There are already a number of tokens held by token contracts themselves. These tokens will not be accessible as there is no function to withdraw them from contract. This tokens are **lost**.

244131 GNT in Golem contract ~ $54333:
https://etherscan.io/token/Golem?a=0xa74476443119a942de498590fe1f2454d7d4ac0d

200 REP in Augur contract ~ $3292:
https://etherscan.io/token/REP?a=0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5

777 DGD in Digix DAO contract ~ $7500:
https://etherscan.io/token/0xe0b7927c4af23765cb51314a0e0521a9645f0e2a?a=0xe0b7927c4af23765cb51314a0e0521a9645f0e2a

10150  1ST in FirstBlood contract ~ $3466:
https://etherscan.io/token/FirstBlood?a=0xaf30d2a7e90d7dc361c8c4585e9bb7d2f6f15bc7
  
30 MLN in Melonport contract ~ $1197:
https://etherscan.io/token/Melon?a=0xBEB9eF514a379B997e0798FDcC901Ee474B6D9A1+
