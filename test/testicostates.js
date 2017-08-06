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

    it("should be running options program after start selling", () => {
        return ico.startIcoForOptions()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(1, s.valueOf(), "State should be 1");
            })
    });

    it("should be running after start", () => {
        return ico.startIco()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(2, s.valueOf(), "State should be 2");
            })
    });

    it("should be paused after pause", () => {
        return ico.pauseIco()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(3, s.valueOf(), "State should be 3");
            })
    });

    it("should be finished after finish", () => {
        return ico.finishIco()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(4, s.valueOf(), "State should be 4");
            })
    });

});
