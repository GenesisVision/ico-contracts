var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");
var GVOptionProgram = artifacts.require("./GVOptionProgram.sol");
var GVOptionToken = artifacts.require("./GVOptionToken.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];
    var account4 = accounts[4];

    var ico;
    var gvt; 

    before('setup', (done) => {
        ICO.deployed().then((_ico) => {
            ico = _ico;
            return ico.initOptionProgram()
        })
        .then(() => {
            return ico.gvToken.call();
        })
        .then((_gvt) => {   
            gvt = GVT.at(_gvt);            
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

    it("should buy 130 GVT by options", () => {
        return ico.buyOptions(account1, 500, "test")
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(130 * 1e18, b.valueOf(), "Balance GVOT 30% should be 130");
                return ico.startIcoForOptionsHolders();
            })
            .then(() => {
                return ico.buyTokensByOptions(account1, 10000, "test")
            })
            .then(() => {
                return gvt.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(130 * 1e18, b.valueOf(), "Balance GVT should be 130");
            })
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(0, b.valueOf(), "Balance Options 30% should be 0 after execution");
            });
    });
});
