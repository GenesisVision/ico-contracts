pragma solidity ^0.4.11;

import './Initable.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';

// Time-locked wallet for Genesis Vision team tokens
contract GVTTeamAllocator is Initable {
    // Address of team member to allocations mapping
    mapping (address => uint256) allocations;

    ERC20Basic gvt;
    uint unlockedAt;
    uint tokensForAllocation;
    address owner;

    function GVTTeamAllocator() {
        unlockedAt = now + 12 * 30 days;
        owner = msg.sender;
        
        allocations[0xC2420A26DE68e097333222cbFe5FBbEE136c1DEC] = 38;
        allocations[0xb205b75E932eC8B5582197052dB81830af372480] = 25;
        allocations[0x48349271Cecd1788dC63c6Fc45bfDbF1B4Eb0E80] = 15;
        allocations[0xeD44E60372AAE7DE227b00277C476dBAB260feF9] = 7;
        allocations[0x36f3dAB9a9408Be0De81681eB5b50BAE53843Fe7] = 5; 
        allocations[0x3dDc2592B66821eF93FF767cb7fF89c9E9C060C6] = 3; 
        allocations[0xfD3eBadDD54cD61e37812438f60Fb9494CBBe0d4] = 2;
        allocations[0xfE8B87Ae4fe6A565791B0cBD5418092eb2bE9647] = 2;
        allocations[0x04FF8Fac2c0dD1EB5d28B0D7C111514055450dDC] = 1;           
        allocations[0x1cd5B39373F52eEFffb5325cE4d51BCe3d1353f0] = 1;       
        allocations[0xFA9930cbCd53c9779a079bdbE915b11905DfbEDE] = 1;        
              
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