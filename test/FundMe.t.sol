//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();

        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view{
        console.log(msg.sender); // msg.sender is us calling the sender address which isn't the one that deploys the contract
        console.log("fundMe sender: ", fundMe.i_owner());

        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view{
        uint256 version = fundMe.getVersion();

        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); 

        fundMe.fund();
    }


    function testFundUpdatesFundedDataStructure() public {

        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

}   
