var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");
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

    it("Time change", () => {
        console.log(web3);
        return web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [60 * 60 * 24 * 365], id: 0});
    });

});

