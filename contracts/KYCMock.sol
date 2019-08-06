pragma solidity >=0.4.22 <0.6.0;

import "./FileShare.sol";


contract KYCMock is KYC {
    mapping(address => bool) authorizedUsers;

    function isAuthorized(address user) external view returns(bool) {
        return authorizedUsers[user];
    }

    function addUser(address user) external {
        authorizedUsers[user] = true;
    }
}