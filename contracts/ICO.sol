pragma solidity ^0.4.11;

import './GVTToken.sol';
import './GVOptionProgram.sol';

contract ICO {

    // Constants
    uint public constant TOKEN_PRICE = 10; // GVT per 100 USD
    uint public constant TOKENS_FOR_SALE = 6000000 * 1e18; // TODO

    // Events
    event RunIco();
    event PauseIco();
    event FinishIco();

    event BuyTokens(address buyer, uint amount, string txHash);
    // State variables
    address public gvAgent; // payments bot account
    address public team;    // team account

    GVTToken public gvtToken;
    GVOptionProgram public optionProgram;

    // Modifiers
    modifier teamOnly { require(msg.sender == team); _; }
    modifier gvAgentOnly { require(msg.sender == gvAgent); _; }

    uint tokensSold = 0;

    enum IcoState { Created, Running, Paused, Finished }
    IcoState public icoState = IcoState.Created;

    function ICO( address _team, address _gvAgent) {
        gvtToken = new GVTToken(this);
        optionProgram = new GVOptionProgram(_gvAgent, _team);
        gvAgent = _gvAgent;
        team = _team;
    }

    function startIco() external teamOnly {
        require(icoState == IcoState.Created || icoState == IcoState.Paused);
        icoState = IcoState.Running;
        RunIco();
    }

    function pauseIco() external teamOnly {
        require(icoState == IcoState.Running);
        icoState = IcoState.Paused;
        PauseIco();
    }

    function finishIco() external teamOnly {
        require(icoState == IcoState.Running || icoState == IcoState.Paused);
        icoState = IcoState.Finished;
        FinishIco();
    }    

    function buyTokens(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(icoState == IcoState.Running);
        require(usdCents > 0);
        uint tokens = usdCents * 1e15; // TODO check it
        require(tokensSold + tokens <= TOKENS_FOR_SALE);

        gvtToken.mint(buyer, tokens);
        BuyTokens(buyer, tokens, txHash);
    }

    function buyOptions(address buyer, uint usdCents, string txHash)
        external gvAgentOnly
    {
        require(icoState == IcoState.Running);
        require(usdCents > 0);
        uint tokens = usdCents * 1e17; // TODO check it
        require(tokensSold + tokens <= TOKENS_FOR_SALE);

        gvtToken.mint(buyer, tokens);
        BuyTokens(buyer, tokens, txHash);
    }

}