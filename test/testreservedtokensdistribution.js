var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVTToken.sol");
var ALLOCATOR = artifacts.require("./GVTTeamAllocator.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];
    var account4 = accounts[4];

    var ico;
    var gvt; 
    var teamAllocator; 

    before('setup', (done) => {
        ICO.deployed().then((_ico) => {
            ico = _ico;
            return ico.gvtToken.call();
        })
        .then((_gvt) => {
            gvt = GVT.at(_gvt);
        })
        .then(() => {
            return ico.teamAllocator.call();
        })
        .then((_teamAllocator) => {
            teamAllocator = ALLOCATOR.at(_teamAllocator);
        })
        .then(() => {            
            return ico.startOptionsSelling()
        })
        .then(() => {
            return ico.startIcoForOptionsHolders()
        })
        .then(() => {
            return ico.startIco()
        })
        .then(() => {
            return ico.buyTokens(account1, 100000, "test")
        })
        .then(() => {
            done();
        });
    });

    it("distribute reserved tokens with 100000 GVT total", () => {
        return ico.finishIco(account2, account3)
            .then(() => {
                return gvt.balanceOf.call(account2)
            })
            .then((b) => {
                assert.equal(6075 * 1e16, b.valueOf(), "Balance should be 60.75");
            })
            .then(() => {
                return gvt.balanceOf.call(account3)
            })
            .then((b) => {
                assert.equal(637875 * 1e14, b.valueOf(), "Balance should be 63.7875");
            })
            .then(() => {
                return gvt.balanceOf.call(teamAllocator.address)
            })
            .then((b) => {
                assert.equal(1366875 * 1e14, b.valueOf(), "Balance should be 136.6875");
            });
    });
});
