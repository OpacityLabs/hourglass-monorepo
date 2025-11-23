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
        IStrategy strategyWeth = IStrategy(vm.envAddress("STRATEGY_WETH_ADDRESS"));
        IStrategy strategySteth = IStrategy(vm.envAddress("STRATEGY_STETH_ADDRESS"));
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
        IStrategy[] memory strategies = new IStrategy[](2);
        strategies[0] = strategyWeth;
        strategies[1] = strategySteth;
        IAllocationManagerTypes.CreateSetParams[] memory createOperatorSetParams =
            new IAllocationManagerTypes.CreateSetParams[](2);

        IStrategy[] memory opsetZero = new IStrategy[](1);
        opsetZero[0] = strategyWeth;
        IStrategy[] memory opsetOne = new IStrategy[](1);
        opsetOne[0] = strategySteth;

        createOperatorSetParams[0] = IAllocationManagerTypes.CreateSetParams({operatorSetId: 0, strategies: opsetZero});
        createOperatorSetParams[1] = IAllocationManagerTypes.CreateSetParams({operatorSetId: 1, strategies: opsetOne});

        allocationManager.createOperatorSets(avs, createOperatorSetParams);
        uint256 operatorSetCount = allocationManager.getOperatorSetCount(avs);
        console.log("Operator sets created:", operatorSetCount);

        vm.stopBroadcast();

        // Write setup results to JSON file
        string memory json = "setup";
        vm.serializeAddress(json, "avs", avs);
        vm.serializeAddress(json, "taskAVSRegistrar", taskAVSRegistrar);
        vm.serializeString(json, "avsMetadataUri", avsMetadataUri);
        vm.serializeAddress(json, "strategyWeth", address(strategyWeth));
        vm.serializeAddress(json, "strategySteth", address(strategySteth));
        vm.writeJson(json, outputPath);
        console.log("Setup results written to:", outputPath);
    }
}
