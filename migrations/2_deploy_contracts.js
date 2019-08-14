var FileShare = artifacts.require("FileShare");
var KYCMock = artifacts.require("KYCMock");

module.exports = function(deployer) {
  deployer.deploy(KYCMock).then(function() {
    return deployer.deploy(FileShare, KYCMock.address);
  })
};
