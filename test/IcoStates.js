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
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(false, p.valueOf(), "ICO should be unpaused");
            })
    });

    it("should be running options selling", () => {
        return ico.initOptionProgram()
            .then(() => {
                ico.startOptionsSelling();
            })
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(1, s.valueOf(), "State should be 1");
            })
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(false, p.valueOf(), "ICO should be unpaused");
            })
    });

    it("should be running options program after finish selling", () => {
        return ico.startIcoForOptionsHolders()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(2, s.valueOf(), "State should be 2");
            })
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(false, p.valueOf(), "ICO should be unpaused");
            })
    });

    it("should be running after start", () => {
        return ico.startIco()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(3, s.valueOf(), "State should be 3");
            })
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(false, p.valueOf(), "ICO should be unpaused");
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
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(true, p.valueOf(), "ICO should be paused");
            })
    });

    it("should be unpaused after resume", () => {
        return ico.resumeIco()
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(3, s.valueOf(), "State should be 3");
            })
            .then(() => {
                return ico.isPaused.call();
            })
            .then((p) => {
                assert.equal(false, p.valueOf(), "ICO should be paused");
            })
    });

    it("should be finished after finish", () => {
        return ico.finishIco(0, 0)
            .then(() => {
                return ico.icoState.call();
            })
            .then((s) => {
                assert.equal(4, s.valueOf(), "State should be 4");
            })
    });
});
