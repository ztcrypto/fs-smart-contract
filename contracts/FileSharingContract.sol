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
        bool is_KYC_needed;
    }

    /// @notice KYC contract address in network
    address     KYC_addr = 0x000000000000000000000000000000000000000A;
    /// @notice KYC object for authorizaton checks
    KYC         contractKYC = KYC(KYC_addr);

    /// @notice maps fileID to file's info
    mapping(bytes32 => FileInfo) files;

    /// @notice checks, whether the sender is the owner of the file
    modifier only_owner(bytes32 fileID) {
        require(
            msg.sender == files[fileID].owner,
            "Only owner can call this function."
        );
        _;
    }

    /// @notice checks, if the user is authorized via KYC
    modifier only_KYC(address account) {
        require(
            contractKYC.isAuthorized(account),
            "KYC authorization needed"
        );
        _;
    }

    /// @notice adds new file
    /// @param fileID file identifier
    /// @param is_KYC_needed uses to check signer's KYC authorization. If a user isn't
    ///        authorized, he can't get access to the file
    function add_file(bytes32 fileID, bool is_KYC_needed) public only_KYC(msg.sender) {
        FileInfo memory file;
        file.owner = msg.sender;
        file.is_KYC_needed = is_KYC_needed;
        files[fileID] = file;
        files[fileID].whitelist[msg.sender] = true;
    }

    /// @notice grants the users access to the file
    /// @param fileID file identifier
    /// @param accounts users, which get access to the file
    function add_access(bytes32 fileID, address[] memory accounts) public
        only_owner(fileID) {

        for (uint i = 0; i < accounts.length; i++) {
            files[fileID].whitelist[accounts[i]] = true;
        }
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param accounts denied users
    function remove_access(bytes32 fileID, address[] memory accounts) public
        only_owner(fileID) {

        for (uint i = 0; i < accounts.length; i++) {
            delete files[fileID].whitelist[accounts[i]];
        }
    }

    /// @notice determines, whether the user has access to the file
    /// @param fileID file identifier
    /// @param account user to check
    /// @return bool, whether the user has access to the file
    function check_access(bytes32 fileID, address account) public view returns(bool) {

        if (files[fileID].is_KYC_needed && !contractKYC.isAuthorized(account)) {
            return false;
        }
        return files[fileID].whitelist[account];
    }
}