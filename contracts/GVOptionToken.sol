pragma solidity ^0.4.12;

// ERC20 interface is implemented only partially.

contract GVOptionToken {
    
    function GVOptionToken(address _tokenManager, address _escrow) {
        tokenManager = tokenManager;
        escrow = _escrow;
    }

    string public constant name = "Genesis Vision Option Token";
    string public constant symbol = "GVOT";
    uint   public constant decimals = 18;

    address public tokenManager;
    address public escrow;
}