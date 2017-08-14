pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVOptionToken is StandardToken {
    
    address public optionProgram;

    string public name;
    string public symbol;
    uint   public constant decimals = 18;

    uint TOKEN_LIMIT;

    modifier optionProgramOnly { require(msg.sender == optionProgram); _; }

    function GVOptionToken(
        address _optionProgram,
        string _name,
        string _symbol,
        uint _TOKEN_LIMIT
    ) {
        optionProgram = _optionProgram;
        name = _name;
        symbol = _symbol;
        TOKEN_LIMIT = _TOKEN_LIMIT;
    }

    function buyOptions(address buyer, uint value, string tx) optionProgramOnly {
        require(value > 0);
        require(totalSupply + value <= TOKEN_LIMIT);

        balances[buyer] += value;
        totalSupply += value;
        Transfer(0x0, buyer, value);
    }
    
    function remainingTokensCount() returns(uint) {
        return TOKEN_LIMIT - totalSupply;
    }
    
    function executeOption(address addr, uint optionsCount) 
        optionProgramOnly
        returns (uint) {
        if (balances[addr] < optionsCount) {
            optionsCount = balances[addr];
        }
        if (optionsCount == 0) {
            return 0;
        }

        balances[addr] -= optionsCount;
        totalSupply -= optionsCount;

        return optionsCount;
    }
}