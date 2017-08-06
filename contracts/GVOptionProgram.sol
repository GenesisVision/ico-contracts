pragma solidity ^0.4.11;

import './GVOptionToken.sol';

contract GVOptionProgram {

    // Constants
    uint option30perCent = 23 * 1e15;  /* /!\ 30% should be 26 ? others too */
    uint option20perCent = 22 * 1e15;
    uint option10perCent  = 21 * 1e15;

    uint option30gvtPrice = 1000; // TODO  /* /!\ should be USD-cent price to execute one option */
    uint option20gvtPrice = 1000; // TODO
    uint option10gvtPrice  = 1000; // TODO

    string public constant option30name = "30% GVOT";
    string public constant option20name = "20% GVOT";
    string public constant option10name = "10% GVOT";

    string public constant option30symbol = "GVOT30";
    string public constant option20symbol = "GVOT20";
    string public constant option10symbol = "GVOT10";

    uint constant option30_TOKEN_LIMIT = 575000 * 1e18;
    uint constant option20_TOKEN_LIMIT = 1650000 * 1e18;
    uint constant option10_TOKEN_LIMIT  = 3300000 * 1e18;  /* /!\ 3300 not evenly divisible by 21 */

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
    OptionsSellingState optionsSellingState = OptionsSellingState.Created;
    
    function GVOptionProgram(address _ico, address _gvAgent, address _team) {
        gvOptionToken30 = new GVOptionToken(this, option30name, option30symbol, option30_TOKEN_LIMIT);
        gvOptionToken20 = new GVOptionToken(this, option20name, option20symbol, option20_TOKEN_LIMIT);
        gvOptionToken10 = new GVOptionToken(this, option10name, option10symbol, option10_TOKEN_LIMIT);
        gvAgent = _gvAgent;
        team = _team;
        ico = _ico;
    }

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

    function executeOptions(address buyer, uint usdCents, string txHash) icoOnly
        returns (uint executedTokens, uint remainingCents) {
        require(optionsSellingState == OptionsSellingState.Finished);
        require(usdCents > 0);

        (executedTokens, remainingCents) = executeIfAvailable(buyer, usdCents, txHash, gvOptionToken30, 0, option30gvtPrice);
        if (remainingCents <= 0) {  /* /!\ uint can't be < 0, use signed int? */
            return (executedTokens, 0);
        }

        uint executed20;
        (executed20, remainingCents) = executeIfAvailable(buyer, remainingCents, txHash, gvOptionToken20, 1, option20gvtPrice);
        if (remainingCents <= 0) {
            return (executedTokens + executed20, 0);
        }

        uint executed10;
        (executed10, remainingCents) = executeIfAvailable(buyer, remainingCents, txHash, gvOptionToken10, 2, option10gvtPrice);
        
        return (executedTokens + executed20 + executed10, remainingCents);
    }

    function buyOptions(address buyer, uint usdCents, string txHash)
        icoOnly {
        require(optionsSellingState == OptionsSellingState.Running);
        require(usdCents > 0);

        var remainUsdCents = buyIfAvailable(buyer, usdCents, txHash, gvOptionToken30, 0, option30perCent);
        if (remainUsdCents <= 0) {  /* /!\ uint can't be < 0, use signed int? */
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, remainUsdCents, txHash, gvOptionToken20, 1, option20perCent);
        if (remainUsdCents <= 0) {
            return;
        }

        remainUsdCents = buyIfAvailable(buyer, remainUsdCents, txHash, gvOptionToken10, 2, option10perCent);
        // TODO
    }   

    function executeIfAvailable(address buyer, uint usdCents, string txHash,
        GVOptionToken optionToken, uint8 optionType, uint gvOptionTokenPrice)
        private returns (uint executedTokens, uint remainingCents) {
        
        var optionsAmount = usdCents * gvOptionTokenPrice;
        executedTokens = optionToken.executeOption(buyer, optionsAmount);
        remainingCents = usdCents - (executedTokens / gvOptionTokenPrice);

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
                BuyOptions(buyer, tokens, txHash, optionType);  /* /!\ incorrect log: we sold 'availableTokens', not 'tokens' */
                return usdCents - availableTokens / optionsPerCent;
            }
        }
        return usdCents;
    }
}