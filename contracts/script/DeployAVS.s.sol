// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {DeployAVSL1Contracts} from "../lib/hourglass-monorepo/contracts/script/local/DeployAVSL1Contracts.s.sol";

contract DeployAVS is DeployAVSL1Contracts {
    // constructor() DeployAVSL1Contracts() {
    //     // ethereum mainnet
    //     ALLOCATION_MANAGER = IAllocationManager(0x42583067658071247ec8CE0A516A58f682002d07);
    //     KEY_REGISTRAR = IKeyRegistrar(0x78De554Ac8DfF368e3CAa73B3Df8AccCfD92928A);
    // }
}