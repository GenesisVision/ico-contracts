pragma solidity ^0.4.11;

import './GVTToken.sol';
import './GVOptionProgram.sol';

contract ICO {

    // Constants
    uint public constant TOKEN_PRICE = 10; // GVT per 100 USD
    uint public constant TOKENS_FOR_SALE = 6000000 * 1e18; // TODO
    uint public constant SNM_PER_SPT = 4; // Migration rate

    // Events
    event RunIco();
    event PauseIco();
    event FinishIco();

    // State variables
    address public gvAgent; // payments bot account
    address public team;    // team account

    GVTToken gvtToken;
    GVOptionProgram optionProgram;

    // Modifiers
    modifier teamOnly { require(msg.sender == team); _; }
    modifier gvAgentOnly { require(msg.sender == gvAgent); _; }

    enum IcoState { Created, Running, Paused, Finished }
    IcoState public icoState = IcoState.Created;

    function ICO(address _gvAgent, address _team) {
        gvtToken = new GVTToken(this);
        optionProgram = new GVOptionProgram(_gvAgent, _team);
        gvAgent = _gvAgent;
        team = _team;
    }

    function startOptionsSelling() external teamOnly {
        require(icoState == IcoState.Created || icoState == IcoState.Paused);
        icoState = IcoState.Running;
        RunIco();
    }

    function pauseOptionsSelling() external teamOnly {
        require(icoState == IcoState.Running);
        icoState = IcoState.Paused;
        PauseIco();
    }

    function finishOptionsSelling() external teamOnly {
        require(icoState == IcoState.Running || icoState == IcoState.Paused);
        icoState = IcoState.Finished;
        FinishIco();
    }    
}