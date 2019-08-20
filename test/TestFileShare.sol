pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/FileShare.sol";
import "../contracts/KYCMock.sol";
import "./ThrowProxy.sol";


contract TestFileShare {
    function testAccessForNonWhitelisted() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        string memory fileID = "test1";

        fs.addFile(fileID, "");
        Assert.isFalse(fs.checkAccess(fileID, address(0x11110)), "The user shouldn't have access");
    }

    function testAccessForWhitelisted() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test2";

        address person = address(0x11111);
        fs.addFile(fileID, "");
        fs.addParticipant(fileID, person, false, "");
        Assert.isTrue(fs.checkAccess(fileID, person), "The user should have access");
    }

    function testAccessForUserWithoutKYC() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test3";

        address person = address(0x11112);
        fs.addFile(fileID, "");
        fs.addParticipant(fileID, person, true, "");
        Assert.isFalse(fs.checkAccess(fileID, person), "The user shouldn't have access");

        fs.setParticipantKYC(fileID, person, false);
        Assert.isTrue(fs.checkAccess(fileID, person), "The user should have access");
    }

    function testAccessForUserWithKYC() public {
        KYCMock contractKYC = KYCMock(DeployedAddresses.KYCMock());
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test4";

        address person = address(0x11113);
        contractKYC.addUser(person);

        fs.addFile(fileID, "");
        fs.addParticipant(fileID, person, true, "");
        Assert.isTrue(fs.checkAccess(fileID, person), "The user should have access");
    }

    function testOwnerAccessToFile() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test5";

        fs.addFile(fileID, "");
        Assert.isTrue(fs.checkAccess(fileID, address(this)), "Owner should have access to file");
    }

    function testAddFileWithWhitelist() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test6";

        address person1 = address(0x111);
        address person2 = address(0x222);
        address nonWhitelistPerson = address(0x333);

        address[] memory whitelist = new address[](2);
        whitelist[0] = person1;
        whitelist[1] = person2;

        bool[] memory accessList = new bool[](2);
        accessList[0] = false;
        accessList[1] = false;

        fs.addFile(fileID, "");
        fs.addParticipantList(fileID, whitelist, accessList);

        Assert.equal(fs.checkAccess(fileID, person1), true, "Invalid access for whitelisted account");
        Assert.equal(fs.checkAccess(fileID, person1), true, "Invalid access for whitelisted account");
        Assert.equal(fs.checkAccess(fileID, nonWhitelistPerson), false, "Invalid access for non-whitelisted account");
    }

    function testSetKYCAccessForNonWhitelisted() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test7";

        ThrowProxy throwProxy = new ThrowProxy(address(fs));
        fs.addFile(fileID, "");

        address person = address(0x198498);

        Assert.isFalse(fs.checkAccess(fileID, person), "The user shouldn't have access");
        FileShare(address(throwProxy)).setParticipantKYC(fileID, person, true);
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should throw, because person isn't whitelisted");
    }

    function testRemoveAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test8";

        address person = address(0x9071234);
        address[] memory whitelist = new address[](1);
        whitelist[0] = person;
        bool[] memory accessList = new bool[](1);
        accessList[0] = false;

        fs.addFile(fileID, "");
        fs.addParticipantList(fileID, whitelist, accessList);
        fs.removeParticipantList(fileID, whitelist);
        Assert.equal(fs.checkAccess(fileID, person), false, "The account shouldn't have access");
    }

    function testOnlyOwnerModifierInAddAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test9";

        fs.addFile(fileID, "");

        address person = address(0x11171338);
        address[] memory whitelist = new address[](1);
        whitelist[0] = person;
        bool[] memory accessList = new bool[](1);
        accessList[0] = false;

        Assert.isFalse(fs.checkAccess(fileID, person), "There shouldn't be any permissions on the file");

        ThrowProxy throwProxy = new ThrowProxy(address(fs));
        FileShare(address(throwProxy)).addParticipantList(fileID, whitelist, accessList);
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be throw, because sender is not owner");
        Assert.isFalse(fs.checkAccess(fileID, person), "The account shouldn't be whitelisted");

        fs.addParticipantList(fileID, whitelist, accessList);
        Assert.isTrue(fs.checkAccess(fileID, person), "The account should be whitelisted");
    }

    function testOnlyOwnerModifierInRemoveAccess() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test10";

        fs.addFile(fileID, "");

        address person = address(0x11898480);
        address[] memory whitelist = new address[](1);
        whitelist[0] = person;
        bool[] memory accessList = new bool[](1);
        accessList[0] = false;

        fs.addParticipantList(fileID, whitelist, accessList);
        Assert.isTrue(fs.checkAccess(fileID, person), "The account should be whitelisted");

        ThrowProxy throwProxy = new ThrowProxy(address(fs));
        FileShare(address(throwProxy)).removeParticipantList(fileID, whitelist);
        bool r = throwProxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be throw, because sender is not owner");

        fs.removeParticipantList(fileID, whitelist);
        Assert.isFalse(fs.checkAccess(fileID, person), "The account shouldn't be whitelisted");
    }

    function testAddRemoveAccessForManyAccounts() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());
        string memory fileID = "test11";

        uint accountsAmount = 10;
        address[] memory accounts = new address[](accountsAmount);
        bool[] memory accessList = new bool[](accountsAmount);

        fs.addFile(fileID, "");

        for(uint i = 1; i < accountsAmount + 1; i++) {
            accounts[i - 1] = address(i);
            accessList[i - 1] = false;
        }
        fs.addParticipantList(fileID, accounts, accessList);

        for(uint j = 0; j < accountsAmount; j++) {
            Assert.isTrue(fs.checkAccess(fileID, accounts[j]), "The account should be whitelisted");
        }

        fs.removeParticipantList(fileID, accounts);

        for(uint j = 0; j < accountsAmount; j++) {
            Assert.isFalse(fs.checkAccess(fileID, accounts[j]), "The account shouldn't be whitelisted");
        }
    }

    function testAddManyFiles() public {
        FileShare fs = FileShare(DeployedAddresses.FileShare());

        uint filesAmount = 10;
        string[] memory files = new string[](filesAmount);
        files[0] = "0";
        files[1] = "1";
        files[2] = "2";
        files[3] = "3";
        files[4] = "4";
        files[5] = "5";
        files[6] = "6";
        files[7] = "7";
        files[8] = "8";
        files[9] = "9";

        for(uint i = 0; i < filesAmount; i++) {
            files[i] = files[i];
            fs.addFile(files[i], "");
        }

        for(uint j = 0; j < filesAmount; j++) {
            Assert.isTrue(fs.checkAccess(files[j], address(this)), "The owner should be whitelisted");
        }
    }
}
