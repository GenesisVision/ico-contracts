pragma solidity ^0.4.11;

import './GVTToken.sol';
import './GVOptionProgram.sol';
import './GVTTeamAllocator.sol';

// Crowdfunding code for Genesis Vision Project
contract ICO {

    // Constants
    uint public constant TOKENS_FOR_SALE = 30 * 1e6 * 1e18;

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

    // Current total token supply
    uint tokensSold = 0;

    enum IcoState { Created, RunningOptionsSelling, RunningForOptionsHolders, Running, Paused, Finished }
    IcoState public icoState = IcoState.Created;

    // Constructor
    function ICO( address _team, address _gvAgent, address _migrationMaster) {
        gvtToken = new GVTToken(this, _migrationMaster);
        gvAgent = _gvAgent;
        team = _team;
        teamAllocator = new GVTTeamAllocator(gvtToken);
    }

    // Initialize Option Program contract
    function initOptionProgram() external teamOnly {
        if (optionProgram == address(0)) {
            optionProgram = new GVOptionProgram(this, gvAgent, team);
        }
    }

    // ICO and Option Program state management

    function startOptionsSelling() external teamOnly {
        require(icoState == IcoState.Created || icoState == IcoState.Paused);
        // Check if Option Program is initialized
        require(optionProgram != address(0));
        optionProgram.startOptionsSelling();        
        icoState = IcoState.RunningOptionsSelling;
        StartOptionsSelling();
    }

    // Finish options selling and start ICO for the option holders
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
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders || icoState == IcoState.RunningOptionsSelling);
        icoState = IcoState.Paused;
        PauseIco();
    }

    function finishIco(address _fund, address _bounty) external teamOnly {
        require(icoState == IcoState.Running || icoState == IcoState.Paused);
        icoState = IcoState.Finished;

        uint mintedTokens = gvtToken.totalSupply();
        if(mintedTokens > 0)
        {
            uint totalAmount = mintedTokens * 4 / 3;              // 125% tokens
            gvtToken.mint(teamAllocator, 11 * totalAmount / 100); // 11% for team to the time-locked wallet
            gvtToken.mint(_fund, totalAmount / 20);               // 5% for Genesis Vision fund
            gvtToken.mint(_bounty, 9 * totalAmount / 100);        // 9% for Advisers + Bounty
        }
        
        FinishIco();
    }    

    // Buy GVT without options
    function buyTokens(address buyer, uint usdCents, string txHash)
    external gvAgentOnly
    returns (uint) {
        return buyTokensInternal(buyer, usdCents, txHash);
    }

    // Buy GVT for option holders. At first buy GVT with option execution, then buy GVT in regular way if ICO is running
    function buyTokensByOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
        returns (uint) {
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        require(usdCents > 0);

        uint executedTokens; 
        uint remainingCents;
        // Execute options
        (executedTokens, remainingCents) = optionProgram.executeOptions(buyer, usdCents, txHash);

        if (executedTokens > 0) {
            require(tokensSold + executedTokens <= TOKENS_FOR_SALE);
            tokensSold += executedTokens;
            
            gvtToken.mint(buyer, executedTokens);
            BuyTokens(buyer, executedTokens, txHash);
        }

        //Buy GVT for remaining cents without options
        if (icoState == IcoState.Running) {
            return buyTokensInternal(buyer, remainingCents, txHash);
        } else {
            return remainingCents;
        }
    }

    // Buy GVOT during the Option Program
    function buyOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(icoState == IcoState.RunningOptionsSelling);
        optionProgram.buyOptions(buyer, usdCents, txHash);
    }

    // Internal buy GVT without options
    function buyTokensInternal(address buyer, uint usdCents, string txHash)
    internal
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
}