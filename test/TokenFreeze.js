var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVTToken.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];

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
        return ico.buyTokens(account, 1000, "test")
            .then(() => {
                return gvt.balanceOf.call(account)
            })
            .then((b) => {
                assert.equal(10 * 1e18, b.valueOf(), "Balance of account1 should be 10");
            })
            .then(() => {
                return gvt.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(0, b.valueOf(), "Balance of account2 should be 0");
            });
    });

    it("should not be able to transfer GVT before ICO finish", () => {
        return gvt.transfer(account1, 5)
        .then(() => {
            assert(false, "throw expected");
          })
        .catch(() => {
            return gvt.balanceOf.call(account)
        })
        .then((b) => {
            assert.equal(10 * 1e18, b.valueOf(), "Balance of account1 should be 10");
        })
        .then(() => {
            return gvt.balanceOf.call(account1)
        })
        .then((b) => {
            assert.equal(0, b.valueOf(), "Balance of account2 should be 0");
        });
    });

    it("should be able to transfer GVT after ICO finish", () => {
        return ico.finishIco(account2, account3)
        .then(() => {
            return gvt.transfer(account1, 5 * 1e18)
        })
        .then(() => {
            return gvt.balanceOf.call(account)
        })
        .then((b) => {
            assert.equal(5 * 1e18, b.valueOf(), "Balance of account1 should be 5");
        })
        .then(() => {
            return gvt.balanceOf.call(account1)
        })
        .then((b) => {
            assert.equal(5 * 1e18, b.valueOf(), b.valueOf(), "Balance of account2 should be 5");
        });
    });
});
