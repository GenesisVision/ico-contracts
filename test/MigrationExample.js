var ICO = artifacts.require("./ICO.sol");
var GVT = artifacts.require("./GVToken.sol");
var TargetTokenExample = artifacts.require("./TargetTokenExample.sol");
var MigrationAgentExample = artifacts.require("./MigrationAgentExample.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var account1 = accounts[1];
    var account2 = accounts[2];
    var account3 = accounts[3];

    var ico;
    var gvt;
    var migrationAgent;
    var targetToken;

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

    it("should be able so deploy and set agent", () => {
        return MigrationAgentExample.new(gvt.address)
            .then((ma) => {
                migrationAgent = ma;
                return TargetTokenExample.new(migrationAgent.address);
            })
            .then((tt) => {
                targetToken = tt;
                migrationAgent.setTargetToken(targetToken.address)
            }) 
            .then(() => {
                return gvt.setMigrationAgent(migrationAgent.address);
            })
    });

    it("should be able to migrate tokens after agent set", () => {
        return gvt.migrate(5 * 1e18)
            .then(() => {
                return gvt.balanceOf.call(account)
            })
            .then((b) => {
                assert.equal(5 * 1e18, b.valueOf(), "Balance should be 5");
            })
            .then(() => {
                return targetToken.balanceOf.call(account)
            })
            .then((b) => {
                assert.equal(5 * 1e18, b.valueOf(), "Balance should be 5");
            });
    }); 

    it("should not be able to migrate more tokens that left", () => {
        return gvt.migrate(10 * 1e18)
            .then(() => {
                assert(false, "throw expected");
              })
            .catch(() => {
                return true;
            })
    }); 

    it("should not be able to migrate tokens after finalize migration", () => {
        return migrationAgent.finalizeMigration()
            .then(() => {
                return gvt.migrate(5);
            })        
            .then(() => {
                assert(false, "throw expected");
            })
            .catch(() => {
                return true;
            })
    }); 
   

    
});
