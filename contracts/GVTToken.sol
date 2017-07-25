pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVTToken is StandardToken {
    
    // Constants
    string public constant name = "Genesis Vision Token";
    string public constant symbol = "GVT";
    uint   public constant decimals = 18;

    uint constant TOKEN_LIMIT = 6000000 * 1e18; // TODO
    uint constant ICO_TOKEN_PRICE = 10000;
    
    address public optionProgram; // TODO rename

    function GVOptionToken(address _optionProgram) {
        optionProgram = _optionProgram;
    }

    function mint(address holder, uint value) {
        require(msg.sender == optionProgram);
        require(value != 0);
        require(totalSupply + value <= TOKEN_LIMIT);

        balances[holder] += value;
        totalSupply += value;
        Transfer(0x0, holder, value);
    }
}