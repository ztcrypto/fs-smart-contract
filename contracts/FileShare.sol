pragma solidity >=0.4.22 <0.6.0;

/// @title KYC - interface for KYC contract
contract KYC {
    /// @param user user to check
    /// @return bool, whether the user is authorized via KYC
    function isAuthorized(address user) external view returns(bool);
}

/// @title File Sharing smart contract
/// @notice independent smart contract for access permissions management to the
///         files added/created via the Blockcerts products usage
contract FileShare {

    /// @notice Person - user information, stores address and KYC flag
    struct Person {
        /// @notice user address
        address person;
        /// @notice whether to check KYC for user
        bool isKYCNeeded;
    }

    /// @notice FileInfo - file information, needs to store person's permissions for file
    struct FileInfo {
        Person owner;
        mapping(address => Person) whitelist;
        /// @notice space for more data
        string _extension;
    }

    /// @notice events
    event ContractCreated();
    event PersonAdded(string fileID, address person);
    event PersonRemoved(string fileID, address person);
    event FileAdded(address owner, string fileID);
    event ExtensionChanged(string fileID);

    /// @notice KYC object for authorizaton checks
    KYC private _contractKYC;

    /// @notice maps fileID to file's info
    mapping(string => FileInfo) _files;

    /// @notice checks, whether the sender is the owner of the file
    /// @param fileID file identifier
    modifier onlyOwner(string memory fileID) {
        require(
            msg.sender == _files[fileID].owner.person,
            "Only owner can call this function."
        );
        _;
    }

    /// @notice assigns KYC contract address and creates KYC object
    /// @param KYCAddress KYC contract address
    constructor(address KYCAddress) public {
        _contractKYC = KYC(KYCAddress);
        emit ContractCreated();
    }

    /// @notice adds new file
    /// @param fileID file identifier
    function addFile(string memory fileID) public {
        Person memory owner;
        owner.person = msg.sender;
        owner.isKYCNeeded = false;

        FileInfo memory file;
        file.owner = owner;
        _files[fileID] = file;
        _files[fileID].whitelist[msg.sender] = owner;

        emit FileAdded(msg.sender, fileID);
    }

    /// @notice adds new file
    /// @param fileID file identifier
    /// @param persons initial whitelist for file
    function addFile(string calldata fileID, address[] calldata persons, bool[] calldata KYCAccesses) external {
        require(persons.length == KYCAccesses.length, "Persons should be same amount as KYCAccesses");
        addFile(fileID);
        addAccess(fileID, persons, KYCAccesses);
    }


    /// @notice grants the users access to the file
    /// @param fileID file identifier
    /// @param persons users, which get access to the file
    function addAccess(string memory fileID, address[] memory persons, bool[] memory KYCAccesses) public
        onlyOwner(fileID) {
        require(persons.length == KYCAccesses.length, "Persons should be same amount as KYCAccesses");

        for (uint i = 0; i < persons.length; i++) {
            Person memory newPerson;
            newPerson.person = persons[i];
            newPerson.isKYCNeeded = KYCAccesses[i];

            _files[fileID].whitelist[persons[i]] = newPerson;
            emit PersonAdded(fileID, persons[i]);
        }
    }

    /// @notice sets user flag for KYC checking
    /// @param fileID file identifier
    /// @param person user for editing
    /// @param isKYCNeeded new value
    function setKYCAccess(string calldata fileID, address person, bool isKYCNeeded) external
        onlyOwner(fileID) {

        Person storage editedPerson = _files[fileID].whitelist[person];
        require(editedPerson.person != address(0x0), "The person is not in whitelist");
        editedPerson.isKYCNeeded = isKYCNeeded;
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param persons denied users
    function removeAccess(string calldata fileID, address[] calldata persons) external
        onlyOwner(fileID) {

        for (uint i = 0; i < persons.length; i++) {
            delete _files[fileID].whitelist[persons[i]];
            emit PersonRemoved(fileID, persons[i]);
        }
    }

    /// @notice determines, whether the user has access to the file
    /// @param fileID file identifier
    /// @param person user to check
    /// @return bool, whether the user has access to the file
    function checkAccess(string calldata fileID, address person) external view returns(bool) {
        Person storage checkedPerson = _files[fileID].whitelist[person];
        if (checkedPerson.person == address(0x0))
            return false;

        if (checkedPerson.isKYCNeeded && !_contractKYC.isAuthorized(person)) {
            return false;
        }

        return true;
    }

    /// @notice sets FileInfo additional space
    /// @param fileID file identifier
    /// @param extension additional data for file
    function setFileExtension(string calldata fileID, string calldata extension) external
        onlyOwner(fileID) {
        _files[fileID]._extension = extension;
        emit ExtensionChanged(fileID);
    }
}