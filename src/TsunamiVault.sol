// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

contract TsunamiVault {

    using SafeTransferLib for ERC20;


    event Deposit(address indexed user, address indexed _token, uint amount);
    event Withdraw(address indexed user, address indexed _token, uint amount);

    error OnlyOwner();
    error Paused();
    error InsufficientFunds();
    error TokenNotWhitelisted();
    error AmountZero();



    address public owner;
    mapping(address => bool) public whitelist;
    mapping(address => mapping(address => uint)) public userBalance;
    uint8 public pause = 0;
    constructor() {
        owner = msg.sender;

    }

    function pauseContract() public {
        if (msg.sender != owner) revert OnlyOwner();
        pause = 1;
    }

    function unpauseContract() public {
        if (msg.sender != owner) revert OnlyOwner();
        pause = 0;
    }

    function whitelistToken(address _token) public {
        if (msg.sender != owner) revert OnlyOwner();
        whitelist[_token] = true;
    }

    function deposit(address _token, uint _amount) public {
        if (pause == 1) revert Paused();
        if (_amount == 0) revert AmountZero();
        if (!whitelist[_token]) revert TokenNotWhitelisted();
        ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        userBalance[msg.sender][_token] += _amount;
        emit Deposit(msg.sender, _token, _amount);
    }

    function withdraw(address _token, uint _amount) public {
        if (pause == 1) revert Paused();
        if (_amount == 0) revert AmountZero();
        if (_amount > userBalance[msg.sender][_token]) revert InsufficientFunds();
        ERC20(_token).safeTransfer(msg.sender, _amount);
        userBalance[msg.sender][_token] -= _amount;
        emit Withdraw(msg.sender, _token, _amount);
    }

}
