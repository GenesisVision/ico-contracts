pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

// Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract GVToken is StandardToken {
    
    // Constants
    string public constant name = "Genesis Vision Token";
    string public constant symbol = "GVT";
    uint   public constant decimals = 18;
    uint   constant TOKEN_LIMIT = 44 * 1e6 * 1e18; 
    
    address public ico;

    // GVT transfers are blocked until ICO is finished.
    bool public isFrozen = true;

    // Token migration variables
    address public migrationMaster;
    address public migrationAgent;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    // Constructor
    function GVToken(address _ico, address _migrationMaster) {
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

    // Allow token transfer.
    function unfreeze() {
      require(msg.sender == ico);
      isFrozen = false;
    }

    // ERC20 functions
    // =========================

    function transfer(address _to, uint _value) public returns (bool) {
      require(!isFrozen);
      return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
      require(!isFrozen);
      return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool) {
      require(!isFrozen);
      return super.approve(_spender, _value);
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