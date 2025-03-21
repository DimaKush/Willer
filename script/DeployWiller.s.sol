// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/Willer.sol";

contract DeployWiller is Script {
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast();
        
        Willer willer = new Willer();
        
        vm.stopBroadcast();
    }
} 