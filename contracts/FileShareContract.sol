pragma solidity >=0.4.22 <0.6.0;

/// @title KYC - interface for KYC contract
contract KYC {
    /// @param user user to check
    /// @return bool, whether the user is authorized via KYC
    function isAuthorized(address user) external view returns(bool);
}

/// @title File Sharing smart contract
/// @author Egor Nickolayenya
/// @notice independent smart contract for access permissions management to the
///         files added/created via the Blockcerts products usage
contract FileShare {

    /// @notice FileInfo - file information, needs to store account permissions for file
    struct FileInfo {
        address owner;
        mapping(address => bool) whitelist;
        bool isKYCNeeded;
    }

    /// @notice KYC object for authorizaton checks
    KYC contractKYC;

    /// @notice maps fileID to file's info
    mapping(bytes32 => FileInfo) files;

    /// @notice checks, whether the sender is the owner of the file
    modifier onlyOwner(bytes32 fileID) {
        require(
            msg.sender == files[fileID].owner,
            "Only owner can call this function."
        );
        _;
    }

    /// @notice assigns KYC contract address and creates KYC object
    /// @param KYCAddress KYC contract address
    constructor(address KYCAddress) public {
        contractKYC = KYC(KYCAddress);
    }

    /// @notice adds new file
    /// @param fileID file identifier
    /// @param isKYCNeeded uses to check signer's KYC authorization. If a user isn't
    ///        authorized, he can't get access to the file
    function addFile(bytes32 fileID, bool isKYCNeeded) public {
        FileInfo memory file;
        file.owner = msg.sender;
        file.isKYCNeeded = isKYCNeeded;
        files[fileID] = file;
        files[fileID].whitelist[msg.sender] = true;
    }

    /// @notice adds new file
    /// @param fileID file identifier
    /// @param accounts initial whitelist for file
    /// @param isKYCNeeded uses to check signer's KYC authorization. If a user isn't
    ///        authorized, he can't get access to the file
    function addFile(bytes32 fileID, address[] memory accounts, bool isKYCNeeded) public {
        addFile(fileID, isKYCNeeded);
        addAccess(fileID, accounts);
    }


    /// @notice grants the users access to the file
    /// @param fileID file identifier
    /// @param accounts users, which get access to the file
    function addAccess(bytes32 fileID, address[] memory accounts) public
        onlyOwner(fileID) {

        for (uint i = 0; i < accounts.length; i++) {
            files[fileID].whitelist[accounts[i]] = true;
        }
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param accounts denied users
    function removeAccess(bytes32 fileID, address[] memory accounts) public
        onlyOwner(fileID) {

        for (uint i = 0; i < accounts.length; i++) {
            delete files[fileID].whitelist[accounts[i]];
        }
    }

    /// @notice determines, whether the user has access to the file
    /// @param fileID file identifier
    /// @param account user to check
    /// @return bool, whether the user has access to the file
    function checkAccess(bytes32 fileID, address account) public view returns(bool) {

        if (files[fileID].isKYCNeeded && !contractKYC.isAuthorized(account)) {
            return false;
        }
        return files[fileID].whitelist[account];
    }
}