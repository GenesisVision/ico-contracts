var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");
var MigrationAgentExample = artifacts.require("./MigrationAgentExample.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];
    var account4 = accounts[4];

    var ico;
    var gvt;
    var migrationAgent; 

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
            return gvt.migrationAgent.call();               
        })
        .then((_ma) => {
            migrationAgent = MigrationAgentExample.at(_ma);
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
                return ico.finishIco(account2, account3);
            })
            .then(() => {
                return gvt.balanceOf.call(account)
            })
            .then((b) => {
                assert.equal(10 * 1e18, b.valueOf(), "Balance should be 10");
            });
    });

    it("should not be able to migrate tokens before agent set", () => {
        return gvt.migrate(5)
            .then(() => {
                assert(false, "throw expected");
              })
            .catch(() => {
                return true;
            })
    }); 

    it("should be able to migrate tokens after agent set", () => {
        return gvt.setMigrationAgent(MigrationAgentExample.address)
            .then(() => {
                console.log("success");
                return gvt.migrate(5);
            })        
            // .then(() => {
            //     return gvt.balanceOf.call(account);
            // })
            // .then((b) => {
            //     assert.equal(5 * 1e18, b.valueOf(), "Balance should be 5");
            // });
    }); 

    
});
