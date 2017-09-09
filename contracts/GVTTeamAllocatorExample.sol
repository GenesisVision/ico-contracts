pragma solidity ^0.4.11;

import './Initable.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';

// Time-locked wallet for Genesis Vision team tokens
contract GVTTeamAllocatorExample is Initable {
    // Address of team member to allocations mapping
    mapping (address => uint256) allocations;

    ERC20Basic gvt;
    uint unlockedAt;
    uint tokensForAllocation;
    address owner;

    function GVTTeamAllocatorExample(address account1, address account2, address account3) {
        unlockedAt = now + 12 * 30 days;
        owner = msg.sender;
        
        allocations[account1] = 60;
        allocations[account2] = 25;
        allocations[account3] = 15;
    }

    function init(address token) {
        require(msg.sender == owner);
        gvt = ERC20Basic(token);
    }

    // Unlock team member's tokens by transferring them to his address
    function unlock() external {
        require (now >= unlockedAt);

        // Update total number of locked tokens with the first unlock attempt
        if (tokensForAllocation == 0)
            tokensForAllocation = gvt.balanceOf(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var amount = tokensForAllocation * allocation / 100;

        if (!gvt.transfer(msg.sender, amount)) {
            revert();
        }
    }
}