---
sections:
  - title: Core
    contracts:
      - IERC223
      - ERC223
  - title: Hooks
    contracts:
      - IERC223Recipient
  - title: Extensions
    contracts:
      - ERC223Burnable
      - ERC223Mintable
---

This set of interfaces and contracts are all related to the [ERC223 token standard](https://github.com/ethereum/EIPs/issues/223).

The token behavior itself is implemented in the core contracts: `IERC223`, `ERC223`.

Additionally there are interfaces used to develop contracts that handle incoming token transfers: `IERC223Recipient`.

Advanced token contract that supports calls of custom token handler functions is implemented as `ERC223CustomFallback.sol`.
