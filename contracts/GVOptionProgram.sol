pragma solidity ^0.4.11;

import './GVOptionToken.sol';
import './GVOptionToken5.sol';
import './GVOptionToken10.sol';
import './GVOptionToken15.sol';

contract GVOptionProgram {

    // Constants
    uint options15perCent = 23 * 1e15;
    uint options10perCent = 22 * 1e15;
    uint options5perCent  = 21 * 1e15;

    uint option15gvtPrice = 1000; // TODO
    uint option10gvtPrice = 1000; // TODO
    uint option5gvtPrice  = 1000; // TODO

    // Events
    event StartOptionsSelling();
    event PauseOptionsSelling();
    event FinishOptionsSelling();

    event BuyOptions(address buyer, uint amount, string tx, uint8 optionType);
    // State variables
    address public gvAgent; // payments bot account
    address public team;    // team account

    GVOptionToken public gvOptionToken5;
    GVOptionToken public gvOptionToken10;
    GVOptionToken public gvOptionToken15;


    // Modifiers
    modifier teamOnly { require(msg.sender == team); _; }
    modifier gvAgentOnly { require(msg.sender == gvAgent); _; }

    enum OptionsSellingState { Created, Running, Paused, Finished }
    OptionsSellingState optionsSellingState = OptionsSellingState.Created;
    
    function GVOptionProgram(address _gvAgent, address _team) {
        gvOptionToken5 = new GVOptionToken5(this);
        gvOptionToken10 = new GVOptionToken10(this);
        gvOptionToken15 = new GVOptionToken15(this);
        gvAgent = _gvAgent;
        team = _team;
    }

    function startOptionsSelling() external teamOnly { // TODO fix external
        require(optionsSellingState == OptionsSellingState.Created || optionsSellingState == OptionsSellingState.Paused);
        optionsSellingState = OptionsSellingState.Running;
        StartOptionsSelling();
    }

    function pauseOptionsSelling() external teamOnly {
        require(optionsSellingState == OptionsSellingState.Running);
        optionsSellingState = OptionsSellingState.Paused;
        PauseOptionsSelling();
    }

    function finishOptionsSelling() external teamOnly {
        require(optionsSellingState == OptionsSellingState.Running || optionsSellingState == OptionsSellingState.Paused);
        optionsSellingState = OptionsSellingState.Finished;
        FinishOptionsSelling();
    }  

    function executeOptions(address buyer, uint usdCents, string txHash)
        returns (uint) {
        require(optionsSellingState == OptionsSellingState.Finished);
        require(usdCents > 0);

        var remainUsdCents = executeIfAvailable(buyer, usdCents, txHash, gvOptionToken15, 0, option15gvtPrice);
        if (remainUsdCents <= 0) {
            return 0;
        }

        remainUsdCents = executeIfAvailable(buyer, usdCents, txHash, gvOptionToken10, 1, option10gvtPrice);
        if (remainUsdCents <= 0) {
            return 0;
        }

        remainUsdCents = executeIfAvailable(buyer, usdCents, txHash, gvOptionToken5, 2, option5gvtPrice);
        
        return remainUsdCents;
        // TODO
    }

    function buyOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(optionsSellingState == OptionsSellingState.Running);
        require(usdCents > 0);

        var remainUsdCents = buyIfAvailable(buyer, usdCents, txHash, gvOptionToken15, 0, options15perCent);
        if (remainUsdCents <= 0) {
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, usdCents, txHash, gvOptionToken10, 1, options10perCent);
        if (remainUsdCents <= 0) {
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, usdCents, txHash, gvOptionToken5, 2, options5perCent);
        // TODO
    }   

    function executeIfAvailable(address buyer, uint usdCents, string txHash,
        GVOptionToken optionToken, uint8 optionType, uint gvOptionToken)
        private returns (uint) {

        return 0;
        // TODO
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
                BuyOptions(buyer, tokens, txHash, optionType);
                return usdCents - availableTokens / optionsPerCent;
            }
        }
        return usdCents;
    }
}