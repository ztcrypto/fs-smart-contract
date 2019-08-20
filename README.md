# File Sharing contract

This contract controls access to user files via whitelist, owner and KYC.

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `_contractKYC` | `KYC` | `private` | KYC contract object for authetication checks |
| `_files` | `mapping(string => FileInfo)` | `private` | Mapping of files' addresses to information about them |
| `_version` | `uint` | `private` | Counter of emitted events |

## Modifiers

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | `string fileID` - file ID | only owner access modifier |
| `whitelistKYCListLengthCheck` | `address[] participants` - participants list, `bool[] isKYCNeededList` - KYC flags | checks, whether participants list and KYC flags list have same length |

## Event codes

| Code | Value |
|---|---|
| `_contractCreatedCode` | `10001` |
| `_participantAddedCode` | `10002` |
| `_participantListAddedCode` | `10003` |
| `_participantRemovedCode` | `10004` |
| `_participantListRemovedCode` | `10005` |
| `_fileAddedCode` | `10006` |
| `_fileAddedWithWhitelistCode` | `10007` |
| `_participantKYCChangedCode` | `10008` |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `ContractCreated` | `uint code` - event code, `uint version` - version, `address KYCAddress` - address of KYC contract | Emits when contract created |
| `ParticipantAdded` | `uint code` - event code, `uint version` - version, `string fileID` - file ID, `address participant` - user, added to file's whitelist, `bool isKYCNeeded` - "is KYC needed" flag for user | Emits when participant has been added to whitelist |
| `ParticipantListAdded` | `uint code` - event code, `uint version` - version, `string fileID` - file ID, `address[] participants` - users, added to file's whitelist, `bool[] isKYCNeededList` - "is KYC needed" flag for each user | Emits when participants list has been added to whitelist |
| `ParticipantRemoved` | `uint code` - event code, `uint version` - version, `string fileID` - file ID, `address participant` - user, removed from file's whitelist | Emits when participant has been removed from whitelist |
| `ParticipantListRemoved` | `uint code` - event code, `uint version` - version, `string fileID` - file ID, `address[] participants` - users, removed from file's whitelist | Emits when participants list has been removed from whitelist |
| `FileAdded` | `uint code` - event code, `uint version` - version, `address owner` - file owner, `string fileID` - file ID | Emits when new file added |
| `ParticipantKYCChanged` | `uint code` - event code, `uint version` - version, `string fileID` - file ID, `address participant` - whitelisted participant address, `bool isKYCNeeded` - new value of KYC access for participant | Emits when participants KYC flag changes |

## Methods

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `constructor` | -//- | `address KYCAddress` - KYC contract address | `public` | Contract constructor |
| `addFile` | -//- | `string fileID` - new file ID, `string extension` - additional info | `external` | Method to add a new file |
| `_addParticipant` | -//- | `string fileID` - file ID, `address participant` - new address to be added to whitelist, `bool isKYCNeeded` - KYC flag, `string extension` - user additional info | `private` | A method to allow user file access. Uses in other methods to add participant |
| `addParticipant` | -//- | `string fileID` - file ID, `address participant` - new address to be added to whitelist, `bool isKYCNeeded` - KYC flag, `string extension` - user additional info | `external` | A method to allow user file access |
| `addParticipantList` | -//- | `string fileID` - file ID, `address[] participants` - new addresses to be added to whitelist, `bool[] isKYCNeededList` - "is KYC needed" flag for each user | `external` | A method to allow users file access |
| `_removeParticipant` | -//- | `string fileID` - file ID, `address participant` - address to be removed from whitelist | `private` | A method to revoke access to file. Uses in other methods to remove participants |
| `removeParticipant` | -//- | `string fileID` - file ID, `address participant` - address to be removed from whitelist | `external` | A method to revoke access to file |
| `removeParticipantList` | -//- | `string fileID` - file ID, `address[] participants` - addresses to be removed from whitelist | `external` | A method to revoke access to file |
| `setParticipantKYC` | -//- | `string fileID` - file ID, `address participant` - address, that will be edited, `bool isKYCNeeded` - new value for KYC flag | `external` | Sets "is KYC needed" flag for whitelisted participant |
| `checkAccess` | `bool` | `string fileID` - file ID, `address participant` - address that is checked for access permissions | `external view` | Method to check if a user has access to a file |
| `setFileExtension` | -//- | `string fileID` - file ID, `string extension` - additional data for file | `external` | Method to set additional info about file |
| `setParticipantExtension` | -//- | `string fileID` - file ID, `address participant` - participant for editing, `string extension` - additional data for file | `external` | Method to set additional info about whitelisted participant |

> Additionally KYC interface-contract is used via a method:
>
> `function isAuthorized(address account) external view returns(bool);`.
