var FileShare = artifacts.require("./FileShare.sol");
var KYCMock = artifacts.require("./KYCMock.sol");

module.exports = function(deployer) {
  deployer.deploy(KYCMock).then(function() {
    return deployer.deploy(FileShare, KYCMock.address);
  })
};
