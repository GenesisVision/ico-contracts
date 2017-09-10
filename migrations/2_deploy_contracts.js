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
    const team =            '0x5e747502a1c426c1c217caCFA97b076Ce06aB9D6';
    const gvAgent =         '0x4eF3cC88299C075623734990baA272a2ed39939F';
    const migrationMaster = '0xb3B9adB05fd11Db68ffCC036E3EB7AC476A17Ee6';

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
