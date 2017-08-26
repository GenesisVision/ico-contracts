pragma solidity ^0.4.11;

import './GVOptionToken.sol';

contract GVOptionProgram {

    // Constants
    uint constant option30perCent = 26 * 1e16; // GVOT30 tokens per cent during option purchase 
    uint constant option20perCent = 24 * 1e16; // GVOT20 tokens per cent during option purchase
    uint constant option10perCent = 22 * 1e16; // GVOT10 tokens per cent during option purchase
    uint constant token30perCent  = 13684210526315800;  // GVT tokens per cent during execution of GVOT30
    uint constant token20perCent  = 12631578947368500;  // GVT tokens per cent during execution of GVOT20
    uint constant token10perCent  = 11578947368421100;  // GVT tokens per cent during execution of GVOT10

    string public constant option30name = "30% GVOT";
    string public constant option20name = "20% GVOT";
    string public constant option10name = "10% GVOT";

    string public constant option30symbol = "GVOT30";
    string public constant option20symbol = "GVOT20";
    string public constant option10symbol = "GVOT10";

    uint constant option30_TOKEN_LIMIT = 26 * 1e5 * 1e18;
    uint constant option20_TOKEN_LIMIT = 36 * 1e5 * 1e18;
    uint constant option10_TOKEN_LIMIT = 55 * 1e5 * 1e18;

    // Events
    event StartOptionsSelling();
    event PauseOptionsSelling();
    event FinishOptionsSelling();

    event BuyOptions(address buyer, uint amount, string tx, uint8 optionType);
    event ExecuteOptions(address buyer, uint amount, string tx, uint8 optionType);

    // State variables
    address public gvAgent; // payments bot account
    address public team;    // team account
    address public ico;     

    GVOptionToken public gvOptionToken30;
    GVOptionToken public gvOptionToken20;
    GVOptionToken public gvOptionToken10;

    // Modifiers
    modifier icoOnly { require(msg.sender == ico); _; }

    enum OptionsSellingState { Created, Running, Paused, Finished }
    OptionsSellingState public optionsSellingState = OptionsSellingState.Created;
    
    // Constructor
    function GVOptionProgram(address _ico, address _gvAgent, address _team) {
        gvOptionToken30 = new GVOptionToken(this, option30name, option30symbol, option30_TOKEN_LIMIT);
        gvOptionToken20 = new GVOptionToken(this, option20name, option20symbol, option20_TOKEN_LIMIT);
        gvOptionToken10 = new GVOptionToken(this, option10name, option10symbol, option10_TOKEN_LIMIT);
        gvAgent = _gvAgent;
        team = _team;
        ico = _ico;
    }

    // Option Program state management: Start, Pause, Finish
    
    function startOptionsSelling() icoOnly {
        require(optionsSellingState == OptionsSellingState.Created || optionsSellingState == OptionsSellingState.Paused);
        optionsSellingState = OptionsSellingState.Running;
        StartOptionsSelling();
    }

    function pauseOptionsSelling() icoOnly {
        require(optionsSellingState == OptionsSellingState.Running);
        optionsSellingState = OptionsSellingState.Paused;
        PauseOptionsSelling();
    }

    function finishOptionsSelling() icoOnly {
        require(optionsSellingState == OptionsSellingState.Running || optionsSellingState == OptionsSellingState.Paused);
        optionsSellingState = OptionsSellingState.Finished;
        FinishOptionsSelling();
    }  

    //Get ramaining tokens for all types of option tokens
    function getBalance() external 
        returns (uint, uint, uint) {
        require(msg.sender == team);
        return (gvOptionToken30.remainingTokensCount(), gvOptionToken20.remainingTokensCount(), gvOptionToken10.remainingTokensCount());
    }

    // Execute options during the ICO token purchase. Proirity: GVOT30 -> GVOT20 -> GVOT10
    function executeOptions(address buyer, uint usdCents, string txHash) icoOnly
        returns (uint executedTokens, uint remainingCents) {
        require(optionsSellingState == OptionsSellingState.Finished);
        require(usdCents > 0);

        (executedTokens, remainingCents) = executeIfAvailable(buyer, usdCents, txHash, gvOptionToken30, 0, token30perCent);
        if (remainingCents == 0) {
            return (executedTokens, 0);
        }

        uint executed20;
        (executed20, remainingCents) = executeIfAvailable(buyer, remainingCents, txHash, gvOptionToken20, 1, token20perCent);
        if (remainingCents == 0) {
            return (executedTokens + executed20, 0);
        }

        uint executed10;
        (executed10, remainingCents) = executeIfAvailable(buyer, remainingCents, txHash, gvOptionToken10, 2, token10perCent);
        
        return (executedTokens + executed20 + executed10, remainingCents);
    }

    // Buy option tokens. Proirity: GVOT30 -> GVOT20 -> GVOT10
    function buyOptions(address buyer, uint usdCents, string txHash)
        icoOnly {
        require(optionsSellingState == OptionsSellingState.Running);
        require(usdCents > 0);

        var remainUsdCents = buyIfAvailable(buyer, usdCents, txHash, gvOptionToken30, 0, option30perCent);
        if (remainUsdCents == 0) {
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, remainUsdCents, txHash, gvOptionToken20, 1, option20perCent);
        if (remainUsdCents == 0) {
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, remainUsdCents, txHash, gvOptionToken10, 2, option10perCent);
    }   

    // Private functions
    
    function executeIfAvailable(address buyer, uint usdCents, string txHash,
        GVOptionToken optionToken, uint8 optionType, uint optionPerCent)
        private returns (uint executedTokens, uint remainingCents) {
        
        var optionsAmount = usdCents * optionPerCent;
        executedTokens = optionToken.executeOption(buyer, optionsAmount);
        remainingCents = usdCents - (executedTokens / optionPerCent);
        ExecuteOptions(buyer, executedTokens, txHash, optionType);
        return (executedTokens, remainingCents);
    }

    function buyIfAvailable(address buyer, uint usdCents, string txHash,
        GVOptionToken optionToken, uint8 optionType, uint optionsPerCent)
        private returns (uint) {
        
        var availableTokens = optionToken.remainingTokensCount(); 
        if (availableTokens > 0) {
            var tokens = usdCents * optionsPerCent;
            if(availableTokens >= tokens) {
                optionToken.buyOptions(buyer, tokens, txHash);
                BuyOptions(buyer, tokens, txHash, optionType);
                return 0;
            }
            else {
                optionToken.buyOptions(buyer, availableTokens, txHash);
                BuyOptions(buyer, availableTokens, txHash, optionType);
                return usdCents - availableTokens / optionsPerCent;
            }
        }
        return usdCents;
    }
}