pragma solidity ^0.4.11;

import './GVTToken.sol';

contract GVTTeamAllocator {

    mapping (address => uint256) allocations;

    GVTToken gvt;

    uint unlockedAt;

    uint tokensForAlocation;

    function GVTTeamAllocator(GVTToken _gvt) {
        gvt = _gvt;
        unlockedAt = now + 12 * 30 days;

        //ToDo Fill allocations table
        //allocations[0x0] = 50; 50% of team tokens
    }

    function unlock() external {
        require (now >= unlockedAt);

        if (tokensForAlocation == 0)
            tokensForAlocation = gvt.balanceOf(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var amount = tokensForAlocation * allocation / 100;

        if (!gvt.transfer(msg.sender, amount)) throw;
    }
}