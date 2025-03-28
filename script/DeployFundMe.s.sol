// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    FundMe fundMe; 

    function run() external returns (FundMe) {
        //Before startBroadcast -> Not a "real" tx
        HelpConfig helpConfig = new HelpConfig();

        address ethUsdPriceFeed = helpConfig.activeNetworkConfig();

        vm.startBroadcast();

        fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}

