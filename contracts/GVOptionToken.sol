pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract GVOptionToken is StandardToken {
    
    event ExecuteOptions(address addr, uint optionsCount);
    event BuyOptions(address buyer, uint usdValueX100, string tx);

    address public optionProgram;

    function buyOptions(address buyer, uint value, string tx);
    
    function remainingTokensCount() returns(uint);
    
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