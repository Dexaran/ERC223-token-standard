I deployed TestEtherToken (TET) contract here: 0x02581271ce3A0667485E5067c7B0520f2c043c40

BAD token sourcecode is same with TET. Only names are different. BitcoinAndDash (BAD) token contract here:
0x855940d5ee6E28cBFe5C0EC711753852A5427Ce8

Than I claimed() some TET from here: 0x00B6fa39793D0537C111DF8f6968204F152b4515 (tx: 0x297b0b6105baf5ab3feb6e5b7c289b78c28cf34bfb09e8cfafaedbc0a90cb79a)

Than I sent some TET to my second wallet: 0x00b6fa39793d0537c111df8f6968204f152b4515 (I sent 15000 TET at this tx: 0x864a39b37f7b74a85a0dde3d850b3bf576f0123a16c8b2b10ce946b823231470)

I deployed contractReceiver here: 0x7f1f305303662c455F627548C22899cE3805de17
now contractReceiver will take TET and throw any other ERC23 token transactions or Ether transactions. Any TET transactions in contractReceiver will trigger fallbackToken() and transaction initiators address will be stored at hallOfFame inside contractReceiver.

I sent 145 TET to the contractReceiver and its OK: 0x5ab80abe84214daf8cb72e5fa1fcf0653529455be4d7ece6943c767576a8d851

I sent some BAD tokens (tx: 0x1ea289bd96f30c926939ef7444cd9c76fe71406fd5ce25352a4f3d3826ed8bdf) and it fails as our contractReveiver is not accepting BAD tokens.

Another tx from my second address to contractReceiver: 0x38e58f32f196ee29f90a1a8e7ce102959d3a1cfdb55a1d2ad9b20358f95ff937


In addition you cant accidentally transfer your tokens to another contract address that is not designed for working with this tokens. For example I cant send my TET intor BAD-token-contract like I cant accidentally send Ether in token contract.
 (tx TET intor BAD-contract: 0x7d437ff3c4f934ebb61320a319df33082d0380c54181ccdd4dabe32bc7b79392)