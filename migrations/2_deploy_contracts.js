const TeamAllocator = artifacts.require("./GVTTeamAllocator.sol");
const ICO = artifacts.require("./ICO.sol");

module.exports = function(deployer, network, accounts) {
    const team = accounts[0];
    const gvAgent = accounts[0];
    const migrationMaster = accounts[0];

    var gvToken;

    deployer.deploy(TeamAllocator)
    .then(() => {
        return deployer.deploy(ICO, gvAgent, team, migrationMaster, TeamAllocator.address);
    })
    .then(() => {
        return ICO.deployed();
    })
    .then((ico) => {
        return ico.gvToken.call();
    })
    .then((_gvToken) => {
        gvToken = _gvToken;
        return TeamAllocator.deployed();
    })
    .then((ta) => {
        return ta.init(gvToken);
    });
};
