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

    // Events
    event StartOptionsSelling();
    event PauseOptionsSelling();
    event FinishOptionsSelling();

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

    function startOptionsSelling() external teamOnly {
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

    function buyOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(optionsSellingState == OptionsSellingState.Running);
        require(usdCents > 0);
        var remainUsdCents = usdCents;

        var availableTokens15 = gvOptionToken15.remainingTokensCount(); 
        if (availableTokens15 > 0) {
            var tokens15 = remainUsdCents * options15perCent;
            var tokensToBuy = 0;
            if(availableTokens15 >= tokens15) {
                gvOptionToken15.buyOptions(buyer, tokensToBuy, txHash);
                return; // TODO
            }
            else {
                gvOptionToken15.buyOptions(buyer, availableTokens15, txHash);
                remainUsdCents -= availableTokens15 / options15perCent;
            }
        }

        var availableTokens10 = gvOptionToken10.remainingTokensCount(); 
        if (availableTokens10 > 0) {
            var tokens10 = remainUsdCents * options10perCent;
            var tokensToBuy = 0;
            if(availableTokens10 >= tokens10) {
                gvOptionToken10.buyOptions(buyer, tokensToBuy, txHash);
                return; // TODO
            }
            else {
                gvOptionToken10.buyOptions(buyer, availableTokens10, txHash);
                remainUsdCents -= availableTokens10 / options10perCent;
            }
        }

        var availableTokens5 = gvOptionToken5.remainingTokensCount(); 
        if (availableTokens5 > 0) {
            var tokens5 = remainUsdCents * options10perCent;
            var tokensToBuy = 0;
            if(availableTokens5 >= tokens5) {
                gvOptionToken5.buyOptions(buyer, tokensToBuy, txHash);
                return; // TODO
            }
            else {
                gvOptionToken5.buyOptions(buyer, availableTokens5, txHash);
                remainUsdCents -= availableTokens5 / options10perCent;
            }
        }
        //BuyTokens(buyer, tokens, txHash);
    }   
}