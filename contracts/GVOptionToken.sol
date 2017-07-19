pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVOptionToken is StandardToken {
    
    // Constants
    string public constant name = "Genesis Vision Option Token";
    string public constant symbol = "GVOT";
    uint   public constant decimals = 18;

    uint constant TOKEN_LIMIT = 1000; // TODO
  
    address public optionProgram;
    
    function GVOptionToken(address _optionProgram) {
        optionProgram = _optionProgram;
    }

    function buyOptions(address buyer, uint value) payable external {
        require(msg.sender == optionProgram);
        require(value > 0);
        require(totalSupply + value <= TOKEN_LIMIT);

        balances[buyer] += value;
        totalSupply += value;
        Transfer(0x0, buyer, value);
    }
}