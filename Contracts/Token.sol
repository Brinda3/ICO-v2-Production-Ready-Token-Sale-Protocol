// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/*
AUDIT CONTEXT:
- Simple ERC20 token with custom decimals
- Uses OpenZeppelin implementation for security and standard compliance
- Minting occurs only once during deployment
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KooDoo is ERC20, Ownable {

    /*
     AUDIT NOTE:
    - initialSupply is multiplied by 10^decimals()
    - Since decimals = 12, ensure frontend/backend uses correct unit conversions
    */

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {

        /*
        AUDIT NOTE:
        - Minting entire supply to deployer (owner)
        - Centralization risk: Owner holds 100% supply initially
        - Consider distribution strategy if used in production (ICO, vesting, etc.)
        */

        _mint(msg.sender, initialSupply * 10 ** decimals());
    }


    function decimals() public pure override returns(uint8) {
        return 12;
    }

}
