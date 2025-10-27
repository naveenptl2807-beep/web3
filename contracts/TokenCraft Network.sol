// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DigitalAssetVault {
    address public owner;
    mapping(address => uint256) private assets;

    event AssetDeposited(address indexed user, uint256 amount);
    event AssetWithdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function depositAssets(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        assets[msg.sender] += _amount;
        emit AssetDeposited(msg.sender, _amount);
    }

    function withdrawAssets(uint256 _amount) external {
        require(assets[msg.sender] >= _amount, "Insufficient balance");
        assets[msg.sender] -= _amount;
        emit AssetWithdrawn(msg.sender, _amount);
    }

    function checkBalance(address _user) external view returns (uint256) {
        return assets[_user];
    }
}

