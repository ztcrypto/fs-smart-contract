# File Sharing contract

This contract controls access to user files via whitelist, owner and KYC.

| Field | Type | Key words | Description |
|---|---|---|---|
| `contractKYC` | `KYC` | `public` | KYC contract object for authetication checks |
| `files` | `mapping(bytes32 => FileInfo)` | `public` | Mapping of files' addresses to information about them |

| Modifier | Accepted values | Description |
|---|---|---|
| `onlyOwner` | `bytes32 fileID` - file ID | only owner access modifier |

| Method | Returned value | Argument | Key words | Description |
|---|---|---|---|---|
| `constructor` | -//- | `address KYCAddress` - KYC contract address | `public` | Contract constructor |
| `addFile` | -//- | `bytes32 fileID` - new file ID, `bool isKYCNeeded` - flag to check whitelisted users' KYC status | `public` | Method to add a new file |
| `addFile` | -//- | `bytes32 fileID` - new file ID, `address[] memory accounts` - file whitelist, `bool isKYCNeeded` - flag to check whitelisted users' KYC status | `public` | Reload addFile method from the file's whitelist |
| `addAccess` | -//- | `bytes32 fileID` - file ID, `address[] memory accounts` - new addresses to be added to whitelist | `public` | A method to allow users file access |
| `removeAccess` | -//- | `bytes32 fileID` - file ID, `address[] memory accounts` - addresses to be removed from whitelist | `public` | A method to revoke access to file |
| `checkAccess` | `bool` | `bytes32 fileID` - file ID, `address account` - address that is checked for access permissions | `public view` | Method to check if a user has access to a file |

