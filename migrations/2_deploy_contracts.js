const TeamAllocator = artifacts.require("./GVTTeamAllocator.sol");
const ICO = artifacts.require("./ICO.sol");

module.exports = function(deployer, network, accounts) {
    const team = accounts[0];
    const gvAgent = accounts[0];
    const migrationMaster = accounts[0];

    deployer.deploy(TeamAllocator)
    .then(() => {
        return deployer.deploy(ICO, gvAgent, team, migrationMaster, TeamAllocator.address);
    })
};
