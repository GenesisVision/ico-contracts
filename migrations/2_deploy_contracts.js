const TeamAllocator = artifacts.require("./GVTTeamAllocator.sol");
const ICO = artifacts.require("./ICO.sol");

const testMode = true;

module.exports = function(deployer, network, accounts) {
    return testMode
        ? testDeployment(deployer, network, accounts)
        : realDeployment(deployer, network, accounts)
};

function testDeployment(deployer, network, accounts){
    const team = accounts[0];
    const gvAgent = accounts[0];
    const migrationMaster = accounts[0]; 
    const TeamAllocatorExample = artifacts.require("./GVTTeamAllocatorExample.sol");

    var gvToken;

    deployer.deploy(TeamAllocatorExample, accounts[5], accounts[6], accounts[7])
    .then(() => {
        return deployer.deploy(ICO, team, gvAgent, migrationMaster, TeamAllocatorExample.address);
    })
    .then(() => {
        return ICO.deployed();
    })
    .then((ico) => {
        return ico.gvToken.call();
    })
    .then((_gvToken) => {
        gvToken = _gvToken;
        return TeamAllocatorExample.deployed();
    })
    .then((ta) => {
        return ta.init(gvToken);
    })
}

function realDeployment(deployer, network, accounts){
    const team = accounts[0];
    const gvAgent = accounts[0];
    const migrationMaster = accounts[0];

    var gvToken;

    deployer.deploy(TeamAllocator)
    .then(() => {
        return deployer.deploy(ICO, team, gvAgent, migrationMaster, TeamAllocator.address);
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
}
