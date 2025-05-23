// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local chain
// 2. Keep track of contract address across different chains 
// Sepolia ETH/USD
// Mainnet ETH/USD


pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelpConfig is Script{
//     // If we are on a local anvil, we deploy mocks
//     // Otherwise, grab the existing address from the live network

    uint8 public constant DECIMALS = 8; 
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
            // assertEq(version, 4);
        }
        else if (block.chainid == 1){
            activeNetworkConfig = getEthereumEthConfig();
            // assertEq(version, 6);
        }

        else{
            activeNetworkConfig = getorCreateAnivilEthConfig();
        }
    }


    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        // price feed address

        NetworkConfig memory sepoliaEthConfig = NetworkConfig(
            {
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            }
        );

        return sepoliaEthConfig;
    }


     function getEthereumEthConfig() public pure returns(NetworkConfig memory){
        // price feed address

        NetworkConfig memory ethereumEthConfig = NetworkConfig(
            {
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            }
        );

        return ethereumEthConfig;
    }

    function getorCreateAnivilEthConfig() public returns(NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }


        // Price feed address
        // 1. Deploy the mocks
        // 2. Return the mock address


        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}



