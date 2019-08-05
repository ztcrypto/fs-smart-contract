var FileShare = artifacts.require("./FileShare.sol");

module.exports = function(deployer) {
  deployer.deploy(FileShare, "0x000000000000000000000000000000000000000A");
};
