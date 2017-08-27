pragma solidity ^0.4.11;

import './GVToken.sol';
import './GVOptionProgram.sol';
import './Initable.sol';

// Crowdfunding code for Genesis Vision Project
contract ICO {

    // Constants
    uint public constant TOKENS_FOR_SALE = 33 * 1e6 * 1e18;

    // Events
    event StartOptionsSelling();
    event StartICOForOptionsHolders();
    event RunIco();
    event PauseIco();
    event ResumeIco();
    event FinishIco();

    event BuyTokens(address buyer, uint amount, string txHash);

    address public gvAgent; // payments bot account
    address public team;    // team account

    GVToken public gvToken;
    GVOptionProgram public optionProgram;
    Initable public teamAllocator;
    address public migrationMaster;

    // Modifiers
    modifier teamOnly { require(msg.sender == team); _; }
    modifier gvAgentOnly { require(msg.sender == gvAgent); _; }

    // Current total token supply
    uint tokensSold = 0;

    bool public isPaused = false;
    enum IcoState { Created, RunningOptionsSelling, RunningForOptionsHolders, Running, Finished }
    IcoState public icoState = IcoState.Created;

    // Constructor
    function ICO(address _team, address _gvAgent, address _migrationMaster, address _teamAllocator) {
        gvAgent = _gvAgent;
        team = _team;
        teamAllocator = Initable(_teamAllocator);
        migrationMaster = _migrationMaster;
        gvToken = new GVToken(this, migrationMaster);
    }

    // Initialize Option Program contract
    function initOptionProgram() external teamOnly {
        if (optionProgram == address(0)) {
            optionProgram = new GVOptionProgram(this, gvAgent, team);
        }
    }

    // ICO and Option Program state management
    function startOptionsSelling() external teamOnly {
        require(icoState == IcoState.Created);
        // Check if Option Program is initialized
        require(optionProgram != address(0));    
        icoState = IcoState.RunningOptionsSelling;
        StartOptionsSelling();
    }

    // Finish options selling and start ICO for the option holders
    function startIcoForOptionsHolders() external teamOnly {
        require(icoState == IcoState.RunningOptionsSelling);       
        icoState = IcoState.RunningForOptionsHolders;
        StartICOForOptionsHolders();
    }

    function startIco() external teamOnly {
        require(icoState == IcoState.RunningForOptionsHolders);
        icoState = IcoState.Running;
        RunIco();
    }

    function pauseIco() external teamOnly {
        require(!isPaused);
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders || icoState == IcoState.RunningOptionsSelling);
        isPaused = true;
        PauseIco();
    }

    function resumeIco() external teamOnly {
        require(isPaused);
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders || icoState == IcoState.RunningOptionsSelling);
        isPaused = false;
        ResumeIco();
    }

    function finishIco(address _fund, address _bounty) external teamOnly {
        require(icoState == IcoState.Running);
        icoState = IcoState.Finished;

        uint mintedTokens = gvToken.totalSupply();
        if (mintedTokens > 0) {
            uint totalAmount = mintedTokens * 4 / 3;              // 125% tokens
            gvToken.mint(teamAllocator, 11 * totalAmount / 100); // 11% for team to the time-locked wallet
            gvToken.mint(_fund, totalAmount / 20);               // 5% for Genesis Vision fund
            gvToken.mint(_bounty, 9 * totalAmount / 100);        // 9% for Advisers, Marketing, Bounty
            gvToken.unfreeze();
        }
        
        FinishIco();
    }    

    // Buy GVT without options
    function buyTokens(address buyer, uint usdCents, string txHash)
        external gvAgentOnly returns (uint) {
        require(!isPaused);
        return buyTokensInternal(buyer, usdCents, txHash);
    }

    // Buy GVT for option holders. At first buy GVT with option execution, then buy GVT in regular way if ICO is running
    function buyTokensByOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly returns (uint) {
        require(!isPaused);
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        require(usdCents > 0);

        uint executedTokens; 
        uint remainingCents;
        // Execute options
        (executedTokens, remainingCents) = optionProgram.executeOptions(buyer, usdCents, txHash);

        if (executedTokens > 0) {
            require(tokensSold + executedTokens <= TOKENS_FOR_SALE);
            tokensSold += executedTokens;
            
            gvToken.mint(buyer, executedTokens);
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
        external gvAgentOnly {
        require(!isPaused);
        require(icoState == IcoState.RunningOptionsSelling);
        optionProgram.buyOptions(buyer, usdCents, txHash);
    }

    // Internal buy GVT without options
    function buyTokensInternal(address buyer, uint usdCents, string txHash)
    private returns (uint) {
        require(icoState == IcoState.Running || icoState == IcoState.RunningForOptionsHolders);
        require(usdCents > 0);
        uint tokens = usdCents * 1e16;
        require(tokensSold + tokens <= TOKENS_FOR_SALE);
        tokensSold += tokens;
            
        gvToken.mint(buyer, tokens);
        BuyTokens(buyer, tokens, txHash);

        return 0;
    }
}