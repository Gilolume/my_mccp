var ResContract = artifacts.require("./ResContract.sol");

module.exports = function(deployer) {
  deployer.deploy(ResContract);
};
