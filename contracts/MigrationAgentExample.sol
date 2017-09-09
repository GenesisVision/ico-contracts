pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import * as Source from "./GVToken.sol";
//import * as Target from "./TargetTokenExample.sol";

contract TargetToken is StandardToken {
    
    address public migrationAgent;

    // Constructor
    function TargetToken(address _migrationAgent) {
        migrationAgent = _migrationAgent;
    }

    // Migration related methods
    function createToken(address _target, uint256 _amount) {
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

contract MigrationAgentExample {

    address owner;
    address sourceToken;
    address targetToken;

    uint256 tokenSupply;

    function MigrationAgentExample(address _sourceToken) {
        owner = msg.sender;
        sourceToken = _sourceToken;

        tokenSupply = Source.GVToken(sourceToken).totalSupply();
    }

    function safetyCheck(uint256 _value) private {
        require (targetToken != 0);
        require (Source.GVToken(sourceToken).totalSupply() + TargetToken(targetToken).totalSupply() == tokenSupply - _value);
    }

    function setTargetToken(address _targetToken) {
        require (msg.sender == owner);
        require (targetToken == 0); //Allow this change once only

        targetToken = _targetToken;
    }

    //Interface implementation
    function migrateFrom(address _from, uint256 _value) {
        require (msg.sender == sourceToken);
        require (targetToken != 0);

        //sourceToken has already been updated, but corresponding amount have not been created in the targetToken contract yet
        safetyCheck(_value);

        TargetToken(targetToken).createToken(_from, _value);

        //totalSupply invariant must hold
        safetyCheck(0);
    }

    function finalizeMigration() {
        require (msg.sender == owner);

        safetyCheck(0);

        TargetToken(targetToken).finalizeMigration();

        sourceToken = 0;
        targetToken = 0;

        tokenSupply = 0;
    }
}