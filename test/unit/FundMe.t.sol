//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

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
        console.log("fundMe sender: ", fundMe.getOwner());

        assertEq(fundMe.getOwner(), msg.sender);
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

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFunderBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        console.log("Gas used: ", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;

        assertEq(endingFunderBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFunderBalance);
    }


    function testWithdrawMultipleFunders() public funded{
        uint160 numberOfFunders = 10; // uint160 is used anytime we want to generate addresses from numbers using address(<number>)
        // uint160 startingFunderIndex = 1; 

        for (uint160 i = 0; i < numberOfFunders; i++) {
            // vm.prank for new address
            // vm.deal new address
            // hoax is used for combined prank and deal
            hoax(address(i),SEND_VALUE);

            fundMe.fund{value: SEND_VALUE}();
        }

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;


        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFunderBalance);
    }



    function testWithdrawMultipleFundersCheaperWithdraw() public funded{
        uint160 numberOfFunders = 10; // uint160 is used anytime we want to generate addresses from numbers using address(<number>)
        // uint160 startingFunderIndex = 1; 

        for (uint160 i = 0; i < numberOfFunders; i++) {
            // vm.prank for new address
            // vm.deal new address
            // hoax is used for combined prank and deal
            hoax(address(i),SEND_VALUE);

            fundMe.fund{value: SEND_VALUE}();
        }

        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;


        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert

        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFunderBalance);
    }

}
