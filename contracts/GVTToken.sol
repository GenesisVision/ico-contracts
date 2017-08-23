pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

// Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract GVTToken is StandardToken {
    
    // Constants
    string public constant name = "Genesis Vision Token";
    string public constant symbol = "GVT";
    uint   public constant decimals = 18;
    uint constant TOKEN_LIMIT = 4 * 1e6 * 1e18; 
    
    address public ico;

    // Token migration variables
    address public migrationMaster;
    address public migrationAgent;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    // Constructor
    function GVTToken(address _ico, address _migrationMaster) {
        require(_ico != 0);
        require(_migrationMaster != 0);
        ico = _ico;
        migrationMaster = _migrationMaster;
    }

    // Create tokens
    function mint(address holder, uint value) {
        require(msg.sender == ico);
        require(value > 0);
        require(totalSupply + value <= TOKEN_LIMIT);

        balances[holder] += value;
        totalSupply += value;
        Transfer(0x0, holder, value);
    }

    // Token migration
    function migrate(uint256 value) external {
        require(migrationAgent != 0);
        require(value > 0);
        require(value <= balances[msg.sender]);

        balances[msg.sender] -= value;
        totalSupply -= value;
        totalMigrated += value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Migrate(msg.sender, migrationAgent, value);
    }

    // Set address of migration contract
    function setMigrationAgent(address _agent) external {
        require(migrationAgent == 0);
        require(msg.sender == migrationMaster);
        migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
        require(msg.sender == migrationMaster);
        require(_master != 0);
        migrationMaster = _master;
    }
}