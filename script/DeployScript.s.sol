// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AIRDROPTOKEN.sol";

contract DeployScript is Script {
    function run() external returns (AIRDROPTOKEN) {
        vm.startBroadcast(); // Forge will use the --private-key flag
        
        AIRDROPTOKEN token = new AIRDROPTOKEN();
        
        console.log("AIRDROPTOKEN deployed at:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Token Decimals:", token.decimals());
        console.log("Mint Amount:", token.MINT_AMOUNT());
        console.log("Airdrop Active:", token.airdropActive());
        
        vm.stopBroadcast();
        
        return token;
    }
}