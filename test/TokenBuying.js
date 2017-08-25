var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVTToken.sol");

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
            return ico.gvtToken.call();
        })
        .then((_gvt) => {   
            gvt = GVT.at(_gvt);            
            return ico.startOptionsSelling()
        })
        .then(() => {
            return ico.startIcoForOptionsHolders()
        })
        .then(() => {
            return ico.startIco()
        })
        .then(() => {
            done();
        });
    });

    it("should buy 10 token per 10 usd", () => {
        return ico.buyTokens(account1, 1000, "test")
            .then(() => {
                return gvt.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(10 * 1e18, b.valueOf(), "Balance should be 10");
            });
    });

    it("should buy 50 token per 50 usd", () => {
        return ico.buyTokens(account2, 5000, "test")
            .then(() => {
                return gvt.balanceOf.call(account2)
            })
            .then((b) => {
                assert.equal(50 * 1e18, b.valueOf(), "Balance should be 50");
            });
    });

    it("should buy 1010 token per 1010 usd", () => {
        return ico.buyTokens(account3, 101000, "test")
            .then(() => {
                return gvt.balanceOf.call(account3)
            })
            .then((b) => {
                assert.equal(1010 * 1e18, b.valueOf(), "Balance should be 1010");
            });
    });
});
