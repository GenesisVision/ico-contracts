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
            return ico.initOptionProgram()
        })
        .then(() => {            
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

    it("should buy all option tokens per 500000 usd", () => {
        return ico.buyOptions(account1, 50000000, "test")
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(26 * 1e5 * 1e18, b.valueOf(), "Balance of GVOT30 should be 26 * 1e5 * 1e18");
            })
            .then(() => {
                return gvOptionToken20.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(36 * 1e5 * 1e18, b.valueOf(), "Balance of GVOT20 should be 36 * 1e5 * 1e18");
            })
            .then(() => {
                return gvOptionToken10.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(55 * 1e5 * 1e18, b.valueOf(), "Balance of GVOT10 should be 55 * 1e5 * 1e18");
            });
    });
});