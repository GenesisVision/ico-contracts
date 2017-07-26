var ICO = artifacts.require("./ICO.sol");

contract('ICO', function (accounts) {
    var account = accounts[0];
    var ico;
    
    before('setup', (done) => {
        ICO.deployed().then((_ico) => {
            ico = _ico;
            done();
        })
    });

    it("should deployed ICO contract has created status", () => {
        return ico.icoState.call()
            .then((s) => {
                assert.equal(0, s.valueOf(), "State should be 0");
            })
    });
});
