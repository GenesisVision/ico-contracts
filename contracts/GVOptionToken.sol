pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVOptionToken is StandardToken {
    
    event ExecuteOptions(address addr, uint optionsCount);
    event BuyOptions(address buyer, uint usdValueX100, string tx);

    address public optionProgram;

    string public name;
    string public symbol;
    uint   public constant decimals = 18;

    uint TOKEN_LIMIT;

    function GVOptionToken(
        address _optionProgram,
        string _name,
        string _symbol,
        uint _TOKENT_LIMIT
    ) {
        optionProgram = _optionProgram;
        name = _name;
        symbol = _symbol;
        TOKEN_LIMIT = _TOKENT_LIMIT;
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
    
    // TODO ICO program???
    // Only OptionProgram can execute the option after charging GVT tokens
    function executeOption(address addr, uint optionsCount) {
        require(msg.sender == optionProgram);
        require(balances[addr] >= optionsCount);
        balances[addr] -= optionsCount;
        totalSupply -= optionsCount;
        ExecuteOptions(addr, optionsCount);
    }
}