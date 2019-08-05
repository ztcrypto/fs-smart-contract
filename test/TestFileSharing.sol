pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FileShare.sol";


contract TestFileSharing {
    bytes32 testFileID = bytes32(0x6161610000000000000000000000000000000000000000000000000000000000);

    function testCreateFile() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        bool testIsKYCNeeded = false;
        fs.addFile(testFileID, testIsKYCNeeded);

        (address owner, bool isKYCNeeded) = fs.files(testFileID);
        Assert.equal(owner, address(this), "Invalid owner");
        Assert.equal(isKYCNeeded, testIsKYCNeeded, "Invalid KYC flag");
    }

    function testCheckAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        fs.addFile(testFileID, false);
        Assert.equal(fs.checkAccess(testFileID, address(this)), true, "Invalid access for file owner");
    }

    function testAddFileWithWhitelist() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        address whitelistAccount1 = address(0x1);
        address whitelistAccount2 = address(0x2);
        address nonWhitelistAccount = address(0x3);

        address[] memory whitelist = new address[](2);
        whitelist[0] = whitelistAccount1;
        whitelist[1] = whitelistAccount2;

        fs.addFile(testFileID, whitelist, false);

        Assert.equal(fs.checkAccess(testFileID, whitelistAccount1), true, "Invalid access for whitelisted account");
        Assert.equal(fs.checkAccess(testFileID, whitelistAccount2), true, "Invalid access for whitelisted account");
        Assert.equal(fs.checkAccess(testFileID, nonWhitelistAccount), false, "Invalid access for non-whitelisted account");
    }

    function testAddAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        address whitelistAccount = address(0x1);
        address[] memory whitelist = new address[](1);
        whitelist[0] = whitelistAccount;
        fs.addFile(testFileID, false);
        fs.addAccess(testFileID, whitelist);
        Assert.equal(fs.checkAccess(testFileID, whitelistAccount), true, "Invalid access for whitelisted account");
    }

    function testRemoveAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        address whitelistAccount = address(0x1);
        address[] memory whitelist = new address[](1);
        whitelist[0] = whitelistAccount;
        fs.addFile(testFileID, false);
        fs.addAccess(testFileID, whitelist);
        fs.removeAccess(testFileID, whitelist);
        Assert.equal(fs.checkAccess(testFileID, whitelistAccount), false, "Invalid access for whitelisted account");
    }
}
