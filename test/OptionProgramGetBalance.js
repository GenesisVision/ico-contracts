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

    it("should show full amount of GVOT", () => {
        return optionProgram.getBalance.call()
            .then((b) => {
                assert.equal(26 * 1e5 * 1e18, b.valueOf()[0], "Balance GVOT30 should be: 2.6kk");
                assert.equal(36 * 1e5 * 1e18, b.valueOf()[1], "Balance GVOT20 should be: 3.6kk");
                assert.equal(55 * 1e5 * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk");
            });
    });


    it("should buy 260 GVOT30 per 10 usd", () => {
        return ico.buyOptions(account1, 1000, "test")
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(260 * 1e18, b.valueOf(), "Balance should be 260");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal((2600000 - 260) * 1e18, b.valueOf()[0], "Balance GVOT30 should be: 2.6kk - 260");
                assert.equal(36 * 1e5 * 1e18, b.valueOf()[1], "Balance GVOT20 should be: 3.6kk");
                assert.equal(55 * 1e5 * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk");
            });
    });

    it("should buy all GVOT30 per total 100k usd", () => {
        return ico.buyOptions(account1, 9999000, "test")
            .then(() => {
                return gvOptionToken30.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(26 * 1e5 * 1e18, b.valueOf(), "Balance should be 2.6kk");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal(0, b.valueOf()[0], "Balance GVOT30 should be: 0");
                assert.equal(36 * 1e5 * 1e18, b.valueOf()[1], "Balance GVOT20 should be: 3.6kk");
                assert.equal(55 * 1e5 * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk");
            });
    });

    it("should buy 240 GVOT20 per 10 usd", () => {
        return ico.buyOptions(account1, 1000, "test")
            .then(() => {
                return gvOptionToken20.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(240 * 1e18, b.valueOf(), "Balance should be 240");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal(0, b.valueOf()[0], "Balance GVOT30 should be: 0");
                assert.equal((3600000 - 240) * 1e18, b.valueOf()[1], "Balance GVOT20 should be: 3.6kk - 240");
                assert.equal(55 * 1e5 * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk");
            });
    });

    it("should buy all GVOT20 per total 150k usd", () => {
        return ico.buyOptions(account1, 14999000, "test")
            .then(() => {
                return gvOptionToken20.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(36 * 1e5 * 1e18, b.valueOf(), "Balance should be 3.6kk");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal(0, b.valueOf()[0], "Balance GVOT30 should be: 0");
                assert.equal(0, b.valueOf()[1], "Balance GVOT20 should be: 0");
                assert.equal(55 * 1e5 * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk");
            });
    });

    it("should buy 220 GVOT10 per 10 usd", () => {
        return ico.buyOptions(account1, 1000, "test")
            .then(() => {
                return gvOptionToken10.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(220 * 1e18, b.valueOf(), "Balance should be 220");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal(0, b.valueOf()[0], "Balance GVOT30 should be: 0");
                assert.equal(0, b.valueOf()[1], "Balance GVOT20 should be: 0");
                assert.equal((5500000 - 220) * 1e18, b.valueOf()[2], "Balance GVOT10 should be: 5.5kk - 220");
            });
    });

    it("should buy all GVOT10 per total 250k usd", () => {
        return ico.buyOptions(account1, 24999000, "test")
            .then(() => {
                return gvOptionToken10.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(55 * 1e5 * 1e18, b.valueOf(), "Balance should be 5.5kk");
            })
            .then((b) => {
                return optionProgram.getBalance.call();
            })
            .then((b) => {
                assert.equal(0, b.valueOf()[0], "Balance GVOT30 should be: 0");
                assert.equal(0, b.valueOf()[1], "Balance GVOT20 should be: 0");
                assert.equal(0, b.valueOf()[2], "Balance GVOT10 should be: 0");
            });
    });
});
