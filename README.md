# File Sharing contract

This contract controls access to user files via whitelist, owner and KYC.

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `_contractKYC` | `KYC` | `private` | KYC contract object for authetication checks |
| `_files` | `mapping(string => FileInfo)` | `private` | Mapping of files' addresses to information about them |
| `_eventCounter` | `uint` | `private` | Counter of emitted events |

## Modifiers

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | `string fileID` - file ID | only owner access modifier |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `ContractCreated` | `uint code` - event code | Emits when contract created |
| `PersonListAdded` | `uint code` - event code, `string fileID` - file ID, `address[] persons` - users, added to file's whitelist | Emits when persons list has been added to whitelist |
| `PersonListRemoved` | `uint code` - event code, `string fileID` - file ID, `address[] persons` - users, removed from file's whitelist | Emits when persons list has been removed from whitelist |
| `FileAdded` | `uint code` - event code, `address owner` - file owner, `string fileID` - file ID | Emits when new file added |
| `FileExtensionChanged` | `uint code` - event code, `string fileID` - file ID | Emits when file owner change file's additional information |
| `PersonExtensionChanged` | `uint code` - event code, `string fileID` - file ID, `address person` - whitelisted person address | Emits when file owner change file's additional information |
| `PersonKYCChanged` | `uint code` - event code, `string fileID` - file ID, `address person` - whitelisted person address, `bool newValue` - new value of KYC access for person | Emits when persons KYC flag changes |

## Methods

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `constructor` | -//- | `address KYCAddress` - KYC contract address | `public` | Contract constructor |
| `addFile` | -//- | `string fileID` - new file ID | `public` | Method to add a new file |
| `addFile` | -//- | `string fileID` - new file ID, `address[] persons` - file whitelist | `external` | Overload addFile method from the file's whitelist |
| `addAccess` | -//- | `string fileID` - file ID, `address[] persons` - new addresses to be added to whitelist | `public` | A method to allow users file access |
| `setKYCAccess` | -//- | `string fileID` - file ID, `address person` - address, that will be edited, `bool isKYCNeeded` - new value for KYC flag | `external` | Sets "is KYC needed" flag for whitelisted person |
| `removeAccess` | -//- | `string fileID` - file ID, `address[] persons` - addresses to be removed from whitelist | `external` | A method to revoke access to file |
| `checkAccess` | `bool` | `string fileID` - file ID, `address person` - address that is checked for access permissions | `external view` | Method to check if a user has access to a file |
| `setFileExtension` | -//- | `string fileID` - file ID, `string extension` - additional data for file | `external` | Method to set additional info about file |
| `setPersonExtension` | -//- | `string fileID` - file ID, `address person` - person for editing, `string extension` - additional data for file | `external` | Method to set additional info about whitelisted person |
