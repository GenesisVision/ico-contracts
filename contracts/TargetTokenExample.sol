pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract TargetTokenExample is StandardToken {
    
    address public migrationAgent;

    // Constructor
    function TargetTokenExample(address _migrationAgent) {
        migrationAgent = _migrationAgent;
    }

    // Migration related methods
    function createToken(address _target, uint _amount) {
        require (msg.sender == migrationAgent);

        balances[_target] += _amount;
        totalSupply += _amount;

        Transfer(migrationAgent, _target, _amount);
    }

    function finalizeMigration() {
        require (msg.sender == migrationAgent);

        migrationAgent = 0;
    }
}