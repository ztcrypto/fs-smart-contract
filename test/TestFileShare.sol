pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FileShare.sol";
import "../contracts/ThrowProxy.sol";


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

    function testNonOwnerAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        fs.addFile(testFileID, false);
        address account = address(0x111111111);
        Assert.isFalse(fs.checkAccess(testFileID, account), "Invalid permission for account");
    }

    function testAddFileWithWhitelist() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        address whitelistAccount1 = address(0x111);
        address whitelistAccount2 = address(0x222);
        address nonWhitelistAccount = address(0x333);

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

        address whitelistAccount = address(0x111);
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

    function testOnlyOwnerAddAccessModifier() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        fs.addFile(testFileID, false);

        address account1 = address(0x11111111);
        address[] memory accounts = new address[](1);
        accounts[0] = account1;

        Assert.isFalse(fs.checkAccess(testFileID, account1), "There shouldn't be any permissions on the file");

        ThrowProxy throwProxy = new ThrowProxy(address(fs));
        FileShare(address(throwProxy)).addAccess(testFileID, accounts);
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be throw, because sender is not owner");
        Assert.isFalse(fs.checkAccess(testFileID, account1), "The account can't be whitelisted");

        fs.addAccess(testFileID, accounts);
        Assert.isTrue(fs.checkAccess(testFileID, account1), "The account should be whitelisted");
    }

    function testOnlyOwnerRemoveAccessModifier() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        fs.addFile(testFileID, false);

        address account1 = address(0x11111111);
        address[] memory accounts = new address[](1);
        accounts[0] = account1;

        fs.addAccess(testFileID, accounts);
        Assert.isTrue(fs.checkAccess(testFileID, account1), "The account should be whitelisted");

        ThrowProxy throwProxy = new ThrowProxy(address(fs));
        FileShare(address(throwProxy)).removeAccess(testFileID, accounts);
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be throw, because sender is not owner");

        fs.removeAccess(testFileID, accounts);
        Assert.isFalse(fs.checkAccess(testFileID, account1), "The account shouldn't be whitelisted");
    }

    function testAddRemoveAccessForManyAccounts() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        uint accountsAmount = 10;
        address[] memory accounts = new address[](accountsAmount);

        fs.addFile(testFileID, false);

        for(uint i = 1; i < accountsAmount + 1; i++) {
            accounts[i - 1] = address(i);
        }
        fs.addAccess(testFileID, accounts);

        for(uint j = 0; j < accountsAmount; j++) {
            Assert.isTrue(fs.checkAccess(testFileID, accounts[j]), "The account should be whitelisted");
        }

        fs.removeAccess(testFileID, accounts);

        for(uint j = 0; j < accountsAmount; j++) {
            Assert.isFalse(fs.checkAccess(testFileID, accounts[j]), "The account shouldn't be whitelisted");
        }
    }

    function testAddManyFiles() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        uint filesAmount = 10;
        bytes32[] memory files = new bytes32[](filesAmount);

        for(uint i = 1; i < filesAmount + 1; i++) {
            files[i - 1] = bytes32(i);
            fs.addFile(files[i - 1], false);
        }

        for(uint j = 0; j < filesAmount; j++) {
            Assert.isTrue(fs.checkAccess(files[j], address(this)), "The owner should be whitelisted");
        }
    }
}
