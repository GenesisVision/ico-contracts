pragma solidity ^0.4.11;

import './GVOptionToken.sol';

contract GVOptionToken10 is GVOptionToken {
    
    // Constants
    string public constant name = "Genesis Vision Option Token with 10% bonus";
    string public constant symbol = "GVOT10";
    uint   public constant decimals = 18;

    uint constant TOKEN_LIMIT = 1650000 * 1e18;
  
    function GVOptionToken10(address _optionProgram) {
        optionProgram = _optionProgram;
    }

    function buyOptions(address buyer, uint value, string tx) {
        require(msg.sender == optionProgram);
        require(value > 0);
        require(totalSupply + value <= TOKEN_LIMIT);

        balances[buyer] += value;
        totalSupply += value;
        Transfer(0x0, buyer, value);
    }

    function remainingTokensCount() returns(uint) {
        return TOKEN_LIMIT - totalSupply;
    }
}