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
            return ico.gvtToken.call();
        })
        .then((_gvt) => {
            gvt = GVT.at(_gvt);
            return ico.startIco()
        })
        .then(() => {
            done();
        });
    });

    it("should buy 1 token per 10 usd", () => {
        return ico.buyTokens(account1, 1000, "test")
            .then(() => {
                return gvt.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(1 * 1e18, b.valueOf(), "Balance should be 1");
            });
    });

    it("should buy 5 token per 50 usd", () => {
        return ico.buyTokens(account2, 5000, "test")
            .then(() => {
                return gvt.balanceOf.call(account2)
            })
            .then((b) => {
                assert.equal(5 * 1e18, b.valueOf(), "Balance should be 5");
            });
    });
    it("should buy 101 token per 1010 usd", () => {
        return ico.buyTokens(account3, 101000, "test")
            .then(() => {
                return gvt.balanceOf.call(account3)
            })
            .then((b) => {
                assert.equal(101 * 1e18, b.valueOf(), "Balance should be 101");
            });
    });
});
