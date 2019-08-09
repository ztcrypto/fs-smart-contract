# File Sharing contract

This contract controls access to user files via whitelist, owner and KYC.

## Fields

| Field | Type | Key words | Description |
|---|---|---|---|
| `_contractKYC` | `KYC` | `private` | KYC contract object for authetication checks |
| `_files` | `mapping(string => FileInfo)` | `private` | Mapping of files' addresses to information about them |

## Modifiers

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | `string fileID` - file ID | only owner access modifier |

## Events

| Event | Accepted values | Description |
|---|---|---|
| `ContractCreated` | -//- | Emits when contract created |
| `FileAdded` | `address owner` - file owner, `string fileID` - file ID | Emits when new file added |
| `PersonAdded` | `string fileID` - file ID, `address person` - user, added to file's whitelist | Emits when person has been added to whitelist |
| `PersonRemoved` | `string fileID` - file ID, `address person` - user, removed from file's whitelist | Emits when person has been removed from whitelist |
| `ExtensionChanged` | `string fileID` - file ID | Emits when file owner change file's additional information |

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
