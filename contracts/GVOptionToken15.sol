pragma solidity ^0.4.11;

import './GVOptionToken.sol';

contract GVOptionToken15 is GVOptionToken {
    
    // Constants
    string public constant name = "Genesis Vision Option Token with 15% bonus";
    string public constant symbol = "GVOT15";
    uint   public constant decimals = 18;

    uint constant TOKEN_LIMIT = 575000 * 1e18;
    uint constant ICO_TOKEN_PRICE = 869;

    function buyOptions(address buyer, uint usdValueX100, string tx) {
        require(msg.sender == optionProgram);
        require(usdValueX100 > 0);

        uint tokensCount = (usdValueX100 * 2) / 1000; // TODO

        require(totalSupply + tokensCount <= TOKEN_LIMIT);

        balances[buyer] += tokensCount;
        totalSupply += tokensCount;
        Transfer(0x0, buyer, tokensCount);
        BuyOptions(buyer, usdValueX100, tx);
    }
}