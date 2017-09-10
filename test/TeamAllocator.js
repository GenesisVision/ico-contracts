var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");
var ALLOCATOR = artifacts.require("./GVTTeamAllocatorExample.sol");
const increaseTime = require('./helpers/timeTravel');

contract('ICO Team Allocator', function (accounts) {
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
            return ico.buyTokens(account1, 90000, "test")
        })
        .then(() => {
            return ico.finishIco(account2, account3)
        })
        .then(() => {
            done();
        });
    });

    it("team tokens should not be available", () => {
        return teamAllocator.unlock({from: account1})
            .then(() => {
                assert();
            })
            .catch((err) => {
                // It is ok
            });
    });

    it("team tokens should be available", () => {
        increaseTime(60 * 60 * 24 * 359);

        return teamAllocator.unlock({from: account1})
        .then(() => {
            assert();
        })
        .catch((err) => {
            // It is ok
        });
    });
});

contract('ICO Team Allocator', function (accounts) {
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
            return ico.buyTokens(account1, 3300000000, "test")
        })
        .then(() => {
            return ico.finishIco(account2, account3)
        })
        .then(() => {
            done();
        });
    });

    it("team tokens should be available", () => {
        increaseTime(60 * 60 * 24 * 360);

        return teamAllocator.unlock({from: accounts[5]})
        .then(() => {
            return gvt.balanceOf.call(accounts[5])
        })
        .then((b) => {
            assert.equal((4840000 * 6 / 10) * 1e18, b.valueOf(), "Balance should be 60%");
        })
        .then(() => {
            teamAllocator.unlock({from: accounts[6]})
        })
        .then(() => {
            return gvt.balanceOf.call(accounts[6])
        })
        .then((b) => {
            assert.equal((4840000 / 4) * 1e18, b.valueOf(), "Balance should be 25%");
        })
        .then(() => {
            teamAllocator.unlock({from: accounts[7]})
        })
        .then(() => {
            return gvt.balanceOf.call(accounts[7])
        })
        .then((b) => {
            assert.equal((4840000 * 15 / 100) * 1e18, b.valueOf(), "Balance should be 15%");
        })
    });
});