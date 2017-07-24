pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVOptionToken is StandardToken {
    
    event ExecuteOption(address addr, uint optionsCount);

    address public optionProgram;

    function buyOptions(address buyer, uint value, string tx);

    function GVOptionToken5(address _optionProgram) {
        optionProgram = _optionProgram;
    }

    // TODO ICO program???
    // Only OptionProgram can execute the option after charging GVT tokens
    function executeOption(address addr, uint optionsCount) {
        require(msg.sender == optionProgram);
        require(balances[addr] >= optionsCount);
        balances[addr] -= optionsCount;
        totalSupply -= optionsCount;
        ExecuteOption(addr, optionsCount);
    }
}