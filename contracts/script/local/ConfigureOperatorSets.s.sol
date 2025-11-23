// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {IKeyRegistrar, IKeyRegistrarTypes} from "@eigenlayer-contracts/src/contracts/interfaces/IKeyRegistrar.sol";
import {OperatorSet} from "@eigenlayer-contracts/src/contracts/libraries/OperatorSetLib.sol";

contract ConfigureOperatorSets is Script {
    function setUp() public {}

    function run() external {
        // Get configuration from environment variables
        address keyRegistrarAddress = vm.envAddress("KEY_REGISTRAR_ADDRESS");
        address avsAddress = vm.envAddress("AVS_ADDRESS");
        uint256 avsPrivateKey = vm.envUint("PRIVATE_KEY_AVS");
        string memory outputPath = vm.envString("OUTPUT_JSON_PATH");

        IKeyRegistrar KEY_REGISTRAR = IKeyRegistrar(keyRegistrarAddress);

        console.log("Configuring operator sets for AVS");
        console.log("  AVS Address:", avsAddress);
        console.log("  Key Registrar:", keyRegistrarAddress);

        vm.startBroadcast(avsPrivateKey);

        // Configure aggregator operator set (ID 0) for BN254
        OperatorSet memory operatorSet0 = OperatorSet({avs: avsAddress, id: 0});

        console.log("Configuring operator set 0 (aggregator) for BN254...");
        KEY_REGISTRAR.configureOperatorSet(operatorSet0, IKeyRegistrarTypes.CurveType.BN254);

        vm.stopBroadcast();

        console.log("Successfully configured operator sets");

        // Write configuration results to JSON file
        string memory json = "configOperatorSets";
        vm.serializeAddress(json, "avs", avsAddress);
        vm.serializeAddress(json, "keyRegistrar", keyRegistrarAddress);
        vm.writeJson(json, outputPath);
        console.log("Configuration results written to:", outputPath);
    }
}
