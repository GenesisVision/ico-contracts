pragma solidity ^0.4.11;

import './Initable.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';

// Time-locked wallet for Genesis Vision team tokens
contract GVTTeamAllocator is Initable {
    // Address of team member to allocations mapping
    mapping (address => uint256) allocations;

    ERC20Basic gvt;

    uint unlockedAt;

    uint tokensForAlocation;

    function GVTTeamAllocator() {
        unlockedAt = now + 12 * 30 days;

        //ToDo Fill allocations table
        //allocations[0x0] = 50; 50% of team tokens
    }

    function init(address token) {
        gvt = ERC20Basic(token);
    }

    // Unlock team member's tokens by transferring them to his address
    function unlock() external {
        require (now >= unlockedAt);

        // Update total number of locked tokens with the first unlock attempt
        if (tokensForAlocation == 0)
            tokensForAlocation = gvt.balanceOf(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var amount = tokensForAlocation * allocation / 100;

        if (!gvt.transfer(msg.sender, amount)) throw;
    }
}