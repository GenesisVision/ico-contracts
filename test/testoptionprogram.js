var ICO = artifacts.require("./ICO.sol");
var GVOptionProgram = artifacts.require("./GVOptionProgram.sol");
var GVOptionToken5 = artifacts.require("./GVOptionToken5.sol");
var GVOptionToken10 = artifacts.require("./GVOptionToken10.sol");
var GVOptionToken15 = artifacts.require("./GVOptionToken15.sol");

contract('GVOptionProgram', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];
    var account4 = accounts[4];

    var ico;
    var optionProgram; 
    var gvOptionToken5;
    var gvOptionToken10;
    var gvOptionToken15;

    before('setup', (done) => {
        ICO.deployed().then((_ico) => {
            ico = _ico;
            return ico.optionProgram.call();
        })
        .then((_optionProgram) => {
            optionProgram = GVOptionProgram.at(_optionProgram);
            return optionProgram.startOptionsSelling()
        })
        .then(() => {
            return optionProgram.gvOptionToken5.call();
        })
        .then((op) => {
            gvOptionToken5 = GVOptionToken5.at(op);
        })
        .then(() => {
            return optionProgram.gvOptionToken10.call();
        })
        .then((op) => {
            gvOptionToken10 = GVOptionToken10.at(op);
        })
        .then(() => {
            return optionProgram.gvOptionToken15.call();
        })
        .then((op) => {
            gvOptionToken15 = GVOptionToken15.at(op);
        })
        .then(() => {
            done();
        });
    });

    it("should buy 230 tokens per 10 usd", () => {
        return optionProgram.buyOptions(account1, 1000, "test")
            .then(() => {
                return gvOptionToken15.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(23 * 1e18, b.valueOf(), "Balance should be 230");
            });
    });
});
