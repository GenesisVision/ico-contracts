var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");

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

    it("should buy 33kk tokens per 33kk usd", () => {
        return ico.buyTokens(account1, 33 * 1e8, "test")
            .then(() => {
                return gvt.balanceOf.call(account1)
            })
            .then((b) => {
                assert.equal(33 * 1e6 * 1e18, b.valueOf(), "Balance should be 33kk");
            })
            .then(() => {
                return ico.finishIco(account2, account3);
            })
            .then(() => {
                return gvt.totalSupply();
            })
            .then((s) => {
                assert.equal(44 * 1e6 * 1e18, s.valueOf(), "Total emitted GVT should be 44kk");
            });
        })
    });