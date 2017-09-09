pragma solidity ^0.4.11;

import * as Source from "./GVToken.sol";
import * as Target from "./TargetTokenExample.sol";

contract MigrationAgentExample {

    address owner;
    address sourceToken;
    address targetToken;

    uint tokenSupply;

    function MigrationAgentExample(address _sourceToken) {
        owner = msg.sender;
        sourceToken = _sourceToken;

        tokenSupply = Source.GVToken(sourceToken).totalSupply();
    }

    function safetyCheck(uint _value) private {
        require (targetToken != 0);
        require (Source.GVToken(sourceToken).totalSupply() + Target.TargetTokenExample(targetToken).totalSupply() == tokenSupply - _value);
    }

    function setTargetToken(address _targetToken) external {
        require (msg.sender == owner);
        require (targetToken == 0); //Allow this change once only

        targetToken = _targetToken;
    }

    //Interface implementation
    function migrateFrom(address _from, uint _value) {
        require (msg.sender == sourceToken);
        require (targetToken != 0);

        //sourceToken has already been updated, but corresponding amount have not been created in the targetToken contract yet
        safetyCheck(_value);

        Target.TargetTokenExample(targetToken).createToken(_from, _value);

        //totalSupply invariant must hold
        safetyCheck(0);
    }

    function finalizeMigration() {
        require (msg.sender == owner);

        safetyCheck(0);

        Target.TargetTokenExample(targetToken).finalizeMigration();

        sourceToken = 0;
        targetToken = 0;

        tokenSupply = 0;
    }
}