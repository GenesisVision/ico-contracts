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
            return ico.teamAllocator.call();
        })
        .then((_teamAllocator) => {
            teamAllocator = ALLOCATOR.at(_teamAllocator);
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
            return ico.buyTokens(account1, 90000, "test")
        })
        .then(() => {
            done();
        });
    });

    it("distribute reserved tokens with 90000 GVT total", () => {
        return ico.finishIco(account2, account3)
            .then(() => {
                return gvt.balanceOf.call(account2)
            })
            .then((b) => {
                assert.equal(60 * 1e18, b.valueOf(), "Balance should be 60");
            })
            .then(() => {
                return gvt.balanceOf.call(account3)
            })
            .then((b) => {
                assert.equal(108 * 1e18, b.valueOf(), "Balance should be 108");
            })
            .then(() => {
                return gvt.balanceOf.call(teamAllocator.address)
            })
            .then((b) => {
                assert.equal(132 * 1e18, b.valueOf(), "Balance should be 132");
            });
    });
});
