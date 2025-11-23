// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";

import {
    IAllocationManager,
    IAllocationManagerTypes
} from "@eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IAVSRegistrar} from "@eigenlayer-contracts/src/contracts/interfaces/IAVSRegistrar.sol";
import {IStrategy} from "@eigenlayer-contracts/src/contracts/interfaces/IStrategy.sol";

contract SetupAVSL1 is Script {
    function setUp() public {}

    function run() public {
        // Load addresses from environment variables
        IAllocationManager allocationManager = IAllocationManager(vm.envAddress("ALLOCATION_MANAGER_ADDRESS"));
        IStrategy strategy = IStrategy(vm.envAddress("STRATEGY_ADDRESS"));
        address taskAVSRegistrar = vm.envAddress("TASK_AVS_REGISTRAR_ADDRESS");
        string memory avsMetadataUri = vm.envString("AVS_METADATA_URI");
        string memory outputPath = vm.envString("OUTPUT_JSON_PATH");

        // Load the private key from the environment variable
        uint256 avsPrivateKey = vm.envUint("PRIVATE_KEY_AVS");
        address avs = vm.addr(avsPrivateKey);

        vm.startBroadcast(avsPrivateKey);
        console.log("AVS address:", avs);

        // 1. Update the AVS metadata URI
        allocationManager.updateAVSMetadataURI(avs, avsMetadataUri);
        console.log("AVS metadata URI updated:", avsMetadataUri);

        // 2. Set the AVS Registrar
        allocationManager.setAVSRegistrar(avs, IAVSRegistrar(taskAVSRegistrar));
        console.log("AVS Registrar set:", address(allocationManager.getAVSRegistrar(avs)));

        // 3. Create the operator sets
        IStrategy[] memory strategies = new IStrategy[](1);
        strategies[0] = strategy;
        IAllocationManagerTypes.CreateSetParams[] memory createOperatorSetParams =
            new IAllocationManagerTypes.CreateSetParams[](1);

        IStrategy[] memory opsetZero = new IStrategy[](1);
        opsetZero[0] = strategy;

        createOperatorSetParams[0] = IAllocationManagerTypes.CreateSetParams({operatorSetId: 0, strategies: opsetZero});

        allocationManager.createOperatorSets(avs, createOperatorSetParams);
        uint256 operatorSetCount = allocationManager.getOperatorSetCount(avs);
        console.log("Operator sets created:", operatorSetCount);

        vm.stopBroadcast();

        // Write setup results to JSON file
        string memory json = "setup";
        vm.serializeAddress(json, "avs", avs);
        vm.serializeAddress(json, "taskAVSRegistrar", taskAVSRegistrar);
        vm.serializeString(json, "avsMetadataUri", avsMetadataUri);
        string memory finalJson = vm.serializeAddress(json, "strategy", address(strategy));
        vm.writeJson(finalJson, outputPath);
        console.log("Setup results written to:", outputPath);
    }
}
