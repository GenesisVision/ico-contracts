var ICO = artifacts.require("./ICO.sol");
var GVOptionProgram = artifacts.require("./GVOptionProgram.sol");
var GVOptionToken = artifacts.require("./GVOptionToken.sol");

contract('GVOptionProgram', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];
    var account4 = accounts[4];

    var ico;
    var optionProgram; 
    var gvOptionToken30;
    var gvOptionToken20;
    var gvOptionToken10;

    before('setup', (done) => {
        ICO.deployed().then((_ico) => {
            ico = _ico;
            return ico.startOptionsSelling()
        })
        .then(() =>{
            return ico.optionProgram.call();
        })
        .then((_optionProgram) => {
            optionProgram = GVOptionProgram.at(_optionProgram);
            return optionProgram.gvOptionToken30.call();
        })
        .then((op) => {
            gvOptionToken30 = GVOptionToken.at(op);
        })
        .then(() => {
            return optionProgram.gvOptionToken20.call();
        })
        .then((op) => {
            gvOptionToken20 = GVOptionToken.at(op);
        })
        .then(() => {
            return optionProgram.gvOptionToken10.call();
        })
        .then((op) => {
            gvOptionToken10 = GVOptionToken.at(op);
            done();
        });
    });

    it("should buy 260 tokens per 10 usd", () => {
        return ico.buyOptions(account1, 1000, "test")
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(260000000000000200000, b.valueOf(), "Balance should be 260");
            });
    });
});
