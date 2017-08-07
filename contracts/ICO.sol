pragma solidity ^0.4.11;

import './GVTToken.sol';
import './GVOptionProgram.sol';
import './GVTTeamAllocator.sol';

contract ICO {

    // Constants
    uint public constant TOKENS_FOR_SALE = 6000000 * 1e18; // TODO

    // Events
    event StartOptionsSelling();
    event StartICOForOptionsHolders();
    event RunIco();
    event PauseIco();
    event FinishIco();

    event BuyTokens(address buyer, uint amount, string txHash);
    // State variables
    address public gvAgent; // payments bot account
    address public team;    // team account

    GVTToken public gvtToken;
    GVOptionProgram public optionProgram;
    GVTTeamAllocator public teamAllocator;

    // Modifiers
    modifier teamOnly { require(msg.sender == team); _; }
    modifier gvAgentOnly { require(msg.sender == gvAgent); _; }

    uint tokensSold = 0;

    enum IcoState { Created, RunningOptionsSelling, RunningForOptionsHolders, Running, Paused, Finished }
    IcoState public icoState = IcoState.Created;

    function ICO( address _team, address _gvAgent) {
        gvtToken = new GVTToken(this);
        gvAgent = _gvAgent;
        team = _team;
        teamAllocator = new GVTTeamAllocator(gvtToken);
    }

    function startOptionsSelling() external teamOnly {
        require(icoState == IcoState.Created || icoState == IcoState.Paused);
        if(optionProgram == address(0)) { // TODO is it OK?
            optionProgram = new GVOptionProgram(this, gvAgent, team);
        }
        optionProgram.startOptionsSelling();        
        icoState = IcoState.RunningOptionsSelling;
        StartOptionsSelling();
    }

    function startIcoForOptionsHolders() external teamOnly {
        require(icoState == IcoState.RunningOptionsSelling || icoState == IcoState.Paused);
        optionProgram.finishOptionsSelling();
        icoState = IcoState.RunningForOptionsHolders;
        StartICOForOptionsHolders();
    }

    function startIco() external teamOnly {
        require(icoState == IcoState.RunningForOptionsHolders || icoState == IcoState.Paused);
        icoState = IcoState.Running;
        RunIco();
    }

    function pauseIco() external teamOnly {
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        icoState = IcoState.Paused;  /* /!\ doesn't pause options selling */
        PauseIco();
    }

    function finishIco(address _fund, address _bounty) external teamOnly {
        require(icoState == IcoState.Running || icoState == IcoState.Paused);
        icoState = IcoState.Finished;

        uint mintedTokens = gvtToken.totalSupply();
        if(mintedTokens > 0)
        {
            uint totalAmount = mintedTokens * 200 / 147;
            gvtToken.mint(teamAllocator, 3 * totalAmount / 20);
            gvtToken.mint(_fund, totalAmount / 10);
            gvtToken.mint(_bounty, 3 * totalAmount / 200);
        }
        
        FinishIco();
    }    

    function buyTokens(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
        returns (uint) {

        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        require(usdCents > 0);
        uint tokens = usdCents * 1e16;
        require(tokensSold + tokens <= TOKENS_FOR_SALE);
        tokensSold += tokens;
            
        gvtToken.mint(buyer, tokens);
        BuyTokens(buyer, tokens, txHash);

        return 0;
        }

    function buyTokensByOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
        returns (uint) {
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        require(usdCents > 0);

        uint executedTokens; 
        uint remainingCents;
        (executedTokens, remainingCents) = optionProgram.executeOptions(buyer, usdCents, txHash);

        if (executedTokens > 0) {
            require(tokensSold + executedTokens <= TOKENS_FOR_SALE);
            tokensSold += executedTokens;
            
            gvtToken.mint(buyer, executedTokens);
            BuyTokens(buyer, executedTokens, txHash);
        }

        if (icoState == IcoState.Running) {
            return this.buyTokens(buyer, remainingCents, txHash);
        } else {
            return remainingCents;
        }
    }

    function buyOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(icoState == IcoState.RunningOptionsSelling);
        optionProgram.buyOptions(buyer, usdCents, txHash);
    }
}