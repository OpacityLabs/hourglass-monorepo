// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {IAllocationManager} from "@eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IKeyRegistrar} from "@eigenlayer-contracts/src/contracts/interfaces/IKeyRegistrar.sol";
import {IPermissionController} from "@eigenlayer-contracts/src/contracts/interfaces/IPermissionController.sol";

import {MockTaskAVSRegistrar} from "@eigenlayer-middleware/test/mocks/MockTaskAVSRegistrar.sol";
import {ITaskAVSRegistrarBaseTypes} from "@eigenlayer-middleware/src/interfaces/ITaskAVSRegistrarBase.sol";

contract DeployAVSL1Contracts is Script {
    function setUp() public {}

    function run() public {
        // Load addresses from environment variables
        IAllocationManager allocationManager = IAllocationManager(vm.envAddress("ALLOCATION_MANAGER_ADDRESS"));
        IKeyRegistrar keyRegistrar = IKeyRegistrar(vm.envAddress("KEY_REGISTRAR_ADDRESS"));
        IPermissionController permissionController = IPermissionController(vm.envAddress("PERMISSION_CONTROLLER_ADDRESS"));
        address avs = vm.envAddress("AVS_ADDRESS");
        string memory outputPath = vm.envString("OUTPUT_JSON_PATH");

        // Load the private key from the environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOYER");
        address deployer = vm.addr(deployerPrivateKey);

        // 1. Deploy the TaskAVSRegistrar middleware contract
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deployer address:", deployer);

        // Create initial config
        uint32[] memory executorOperatorSetIds = new uint32[](1);
        executorOperatorSetIds[0] = 1;
        ITaskAVSRegistrarBaseTypes.AvsConfig memory initialConfig = ITaskAVSRegistrarBaseTypes.AvsConfig({
            aggregatorOperatorSetId: 0, executorOperatorSetIds: executorOperatorSetIds
        });

        // Deploy ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin();
        console.log("ProxyAdmin deployed to:", address(proxyAdmin));

        // Deploy implementation
        MockTaskAVSRegistrar taskAVSRegistrarImpl =
            new MockTaskAVSRegistrar(allocationManager, keyRegistrar, permissionController);
        console.log("TaskAVSRegistrar implementation deployed to:", address(taskAVSRegistrarImpl));

        // Deploy proxy with initialization
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(taskAVSRegistrarImpl),
            address(proxyAdmin),
            abi.encodeWithSelector(MockTaskAVSRegistrar.initialize.selector, avs, deployer, initialConfig)
        );
        console.log("TaskAVSRegistrar proxy deployed to:", address(proxy));

        // Transfer ProxyAdmin ownership to avs (or a multisig in production)
        proxyAdmin.transferOwnership(avs);

        vm.stopBroadcast();

        // Write deployment results to JSON file
        string memory json = "deployment";
        vm.serializeAddress(json, "deployer", deployer);
        vm.serializeAddress(json, "avs", avs);
        vm.serializeAddress(json, "proxyAdmin", address(proxyAdmin));
        vm.serializeAddress(json, "taskAVSRegistrarImplementation", address(taskAVSRegistrarImpl));
        string memory finalJson = vm.serializeAddress(json, "taskAVSRegistrarProxy", address(proxy));
        vm.writeJson(finalJson, outputPath);
        console.log("Deployment results written to:", outputPath);
    }
}
