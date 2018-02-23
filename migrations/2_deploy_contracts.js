var ResContract = artifacts.require("./ResContract.sol");
var TokenBTU = artifacts.require("./TokenBTU.sol");

module.exports = function(deployer) {
  deployer.deploy(ResContract);
  deployer.link(ResContract, TokenBTU);
  deployer.deploy(TokenBTU, 12000000000000000000, "TokenBTU", "BTU");
};
