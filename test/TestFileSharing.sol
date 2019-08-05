pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FileShare.sol";


contract TestFileSharing {
    function testBasicAssert() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        Assert.isTrue(true, "Can't be real");
    }
}
