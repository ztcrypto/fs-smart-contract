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

    /// @notice Participant - user information, stores address and KYC flag
    struct Participant {
        /// @notice user address
        address participant;
        /// @notice whether to check KYC for user
        bool isKYCNeeded;
        /// @notice space for more data
        string extension;
    }

    /// @notice FileInfo - file information, needs to store participant's permissions for file
    struct FileInfo {
        /// @notice owner of file
        Participant owner;
        /// @notice file's whitelist
        mapping(address => Participant) whitelist;
        /// @notice space for more data
        string extension;
    }

    /// @notice KYC object for authorizaton checks
    KYC private _contractKYC;

    /// @notice maps fileID to file's info
    mapping(string => FileInfo) _files;

    /// @notice counts number of event
    uint private _version = 0;

    /// @notice event codes
    uint constant _contractCreatedCode = 10001;
    uint constant _participantAddedCode = 10002;
    uint constant _participantListAddedCode = 10003;
    uint constant _participantRemovedCode = 10004;
    uint constant _participantListRemovedCode = 10005;
    uint constant _fileAddedCode = 10006;
    uint constant _fileAddedWithWhitelistCode = 10007;
    uint constant _participantKYCChangedCode = 10008;

    /// @notice events
    event ContractCreated(uint code, uint version, address KYCAddress);
    event ParticipantAdded(uint code, uint version, string fileID, address participant, bool isKYCNeeded);
    event ParticipantListAdded(uint code, uint version, string fileID, address[] participants, bool[] isKYCNeededList);
    event ParticipantRemoved(uint code, uint version, string fileID, address participant);
    event ParticipantListRemoved(uint code, uint version, string fileID, address[] participants);
    event FileAdded(uint code, uint version, address owner, string fileID);
    event ParticipantKYCChanged(uint code, uint version, string fileID, address participant, bool isKYCNeeded);

    /// @notice checks, whether the sender is the owner of the file
    /// @param fileID file identifier
    modifier onlyOwner(string memory fileID) {
        require(
            msg.sender == _files[fileID].owner.participant,
            "Only owner can call this function"
        );
        _;
    }

    /// @notice checks, whether participants list and KYC flags list have same length
    /// @param participants participants list
    /// @param isKYCNeededList KYC flags
    modifier whitelistKYCListLengthCheck(address[] memory participants, bool[] memory isKYCNeededList) {
        require(
            participants.length == isKYCNeededList.length,
            "Participants should be same amount as isKYCNeededList"
        );
        _;
    }

    /// @notice assigns KYC contract address and creates KYC object
    /// @param KYCAddress KYC contract address
    constructor(address KYCAddress) public {
        _contractKYC = KYC(KYCAddress);

        emit ContractCreated(_contractCreatedCode, _version++, KYCAddress);
    }

    /// @notice adds new file
    /// @param fileID file identifier
    /// @param extension file's additional info
    function addFile(string calldata fileID, string calldata extension) external {
        Participant memory owner;
        owner.participant = msg.sender;
        owner.isKYCNeeded = false;

        FileInfo memory file;
        file.owner = owner;
        file.extension = extension;
        _files[fileID] = file;
        _files[fileID].whitelist[msg.sender] = owner;

        emit FileAdded(_fileAddedCode, _version++, msg.sender, fileID);
    }

    /// @notice grants the user access to the file
    /// @param fileID file identifier
    /// @param participant user, which get access to the file
    /// @param isKYCNeeded KYC flag for participant
    /// @param extension user additional data
    function _addParticipant(string memory fileID, address participant,
                             bool isKYCNeeded, string memory extension) private {
        Participant memory newParticipant;
        newParticipant.participant = participant;
        newParticipant.isKYCNeeded = isKYCNeeded;
        newParticipant.extension = extension;

        _files[fileID].whitelist[participant] = newParticipant;
    }

    /// @notice grants the user access to the file
    /// @param fileID file identifier
    /// @param participant user, which get access to the file
    /// @param isKYCNeeded KYC flag for participant
    /// @param extension user additional data
    function addParticipant(string calldata fileID, address participant,
                            bool isKYCNeeded, string calldata extension) external onlyOwner(fileID) {
        _addParticipant(fileID, participant, isKYCNeeded, extension);

        emit ParticipantAdded(_participantAddedCode, _version++, fileID, participant, isKYCNeeded);
    }

    /// @notice grants the users access to the file
    /// @param fileID file identifier
    /// @param participants users, which get access to the file
    /// @param isKYCNeededList list of KYC flags for participants
    function addParticipantList(string calldata fileID, address[] calldata participants,
                                bool[] calldata isKYCNeededList) external
            onlyOwner(fileID) whitelistKYCListLengthCheck(participants, isKYCNeededList) {

        for (uint i = 0; i < participants.length; i++)
            _addParticipant(fileID, participants[i], isKYCNeededList[i], "");

        emit ParticipantListAdded(_participantListAddedCode, _version++, fileID, participants, isKYCNeededList);
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param participant denied user
    function _removeParticipant(string memory fileID, address participant) private {
        delete _files[fileID].whitelist[participant];
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param participant denied user
    function removeParticipant(string calldata fileID, address participant) external onlyOwner(fileID) {
        _removeParticipant(fileID, participant);

        emit ParticipantRemoved(_participantRemovedCode, _version++, fileID, participant);
    }

    /// @notice removes user access to a file
    /// @param fileID file identifier
    /// @param participants denied users
    function removeParticipantList(string calldata fileID, address[] calldata participants) external
            onlyOwner(fileID) {

        for (uint i = 0; i < participants.length; i++)
            _removeParticipant(fileID, participants[i]);

        emit ParticipantListRemoved(_participantListRemovedCode, _version++, fileID, participants);
    }

    /// @notice sets user flag for KYC checking
    /// @param fileID file identifier
    /// @param participant user for editing
    /// @param isKYCNeeded new value
    function setParticipantKYC(string calldata fileID, address participant, bool isKYCNeeded) external
            onlyOwner(fileID) {

        Participant storage editedParticipant = _files[fileID].whitelist[participant];
        require(editedParticipant.participant != address(0x0), "The participant is not in whitelist");
        editedParticipant.isKYCNeeded = isKYCNeeded;

        emit ParticipantKYCChanged(_participantKYCChangedCode, _version++, fileID, participant, isKYCNeeded);
    }

    /// @notice determines, whether the user has access to the file
    /// @param fileID file identifier
    /// @param participant user to check
    /// @return bool, whether the user has access to the file
    function checkAccess(string calldata fileID, address participant) external view returns(bool) {
        Participant storage checkedParticipant = _files[fileID].whitelist[participant];
        if (checkedParticipant.participant == address(0x0))
            return false;

        if (checkedParticipant.isKYCNeeded && !_contractKYC.isAuthorized(participant)) {
            return false;
        }

        return true;
    }

    /// @notice sets FileInfo additional space
    /// @param fileID file identifier
    /// @param extension additional data for file
    function setFileExtension(string calldata fileID, string calldata extension) external
            onlyOwner(fileID) {
        _files[fileID].extension = extension;
    }

    /// @notice sets Participant additional space
    /// @param fileID file identifier
    /// @param participant participant address
    /// @param extension additional data for whitelisted participant
    function setParticipantExtension(string calldata fileID, address participant, string calldata extension) external
            onlyOwner(fileID) {
        Participant storage editedParticipant = _files[fileID].whitelist[participant];
        if (editedParticipant.participant != address(0x0)) {
            editedParticipant.extension = extension;
        }
    }
}