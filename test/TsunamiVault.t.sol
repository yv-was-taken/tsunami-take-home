// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { TsunamiVault } from "../src/TsunamiVault.sol";



contract CustomCoin is ERC20 {
    constructor() ERC20("Dummy ", "DUMMY", 18) {}

    function mint(uint amount) public {
        _mint(msg.sender, amount);
    }
}

contract TsunamiVaultTest is Test {
    event Deposit(address indexed user, address indexed _token, uint amount);
    event Withdraw(address indexed user, address indexed _token, uint amount);

    error OnlyOwner();
    error Paused();
    error InsufficientFunds();
    error TokenNotWhitelisted();
    error AmountZero();

    TsunamiVault public Vault;
    CustomCoin public Token1;
    CustomCoin public Token2;


    address private actor1 = vm.addr(uint256(keccak256(abi.encodePacked("actor1"))));
    address private actor2 = vm.addr(uint256(keccak256(abi.encodePacked("actor2"))));



    function setUp() public {
        Vault = new TsunamiVault();
        Token1 = new CustomCoin();
        Token2 = new CustomCoin();

        vm.deal(actor1, 100 ether);
        vm.deal(actor2, 100 ether);

        Token1.mint(100);
        Token2.mint(100);

        Token1.transfer(actor1, 50);
        Token1.transfer(actor2, 50);
        Token2.transfer(actor1, 50);
        Token2.transfer(actor2, 50);




    }

    function test_whiteListTokens_success() public {
        Vault.whitelistToken(address(Token1));
        assertEq(Vault.whitelist(address(Token1)), true);
    }
    function test_whitelistTokens_expect_token_not_whitelisted() public {
        Vault.whitelistToken(address(Token2));
        assertEq(Vault.whitelist(address(Token1)), false);

    }

    function test_whitelistTokens_revert_tokens_OnlyOwner() public {
        vm.startPrank(actor1);
        vm.expectRevert(OnlyOwner.selector);
        Vault.whitelistToken(address(Token1));


    }

    function test_pauseContract_pause_success() public {
        uint8 expectedPauseStatus = 1;
        Vault.pauseContract();
        assertEq(Vault.pause(), expectedPauseStatus);

    }
    function test_pauseContract_unpause_success() public {
        uint8 expectedPauseStatus = 0;
        Vault.pauseContract();
        Vault.unpauseContract();
        assertEq(Vault.pause(), expectedPauseStatus);

    }
    function test_pauseContract_revert_pause_OnlyOwner() public {
        vm.startPrank(actor1);
        vm.expectRevert(OnlyOwner.selector);
        Vault.pauseContract();

    }
    function test_pauseContract_revert_unpause_OnlyOwner() public {
        vm.startPrank(actor1);
        vm.expectRevert(OnlyOwner.selector);
        Vault.unpauseContract();

    }

    function test_deposit_success_execution() public {
        //testing deposit flow success without revert
        uint depositAmount = 10;
        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        vm.expectEmit(true, true, true, false);
        emit Deposit(actor1, address(Token1), depositAmount);
        Vault.deposit(address(Token1), depositAmount);

    }
    function test_deposit_success_balance_updated_as_expected() public {
        //ensuring vault balances are updated accordingly
        uint depositAmount = 10;

        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        Vault.deposit(address(Token1), depositAmount);

        uint userVaultBalance = Vault.userBalance(actor1, address(Token1));
        assertEq(userVaultBalance, depositAmount);

    }
    function test_deposit_success_balance_for_different_tokens_updated_separately() public {
        //ensuring balances are recorded separately for separate whitelisted token deposits


        uint depositAmountToken1 = 10;
        Vault.whitelistToken(address(Token1));

        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmountToken1);
        Vault.deposit(address(Token1), depositAmountToken1);
        vm.stopPrank();

        uint depositAmountToken2 = 20;
        Vault.whitelistToken(address(Token2));

        vm.startPrank(actor1);
        Token2.approve(address(Vault), depositAmountToken2);
        Vault.deposit(address(Token2), depositAmountToken2);
        vm.stopPrank();

        uint userVaultBalanceToken1 = Vault.userBalance(actor1, address(Token1));
        uint userVaultBalanceToken2 = Vault.userBalance(actor1, address(Token2));

        assertEq(userVaultBalanceToken1, depositAmountToken1);
        assertEq(userVaultBalanceToken2, depositAmountToken2);
    }

    function test_deposit_revert_Paused() public {
        Vault.whitelistToken(address(Token1));
        Vault.pauseContract();
        vm.startPrank(actor1);
        uint depositAmount = 10;
        Token1.approve(address(Vault), depositAmount);
        vm.expectRevert(Paused.selector);
        Vault.deposit(address(Token1), depositAmount);

    }
    function test_deposit_revert_AmountZero() public {

        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), 0);
        vm.expectRevert(AmountZero.selector);
        Vault.deposit(address(Token1), 0);

    }
    function test_deposit_revert_TokenNotWhitelisted() public {
        uint depositAmount = 10;
        Vault.whitelistToken(address(Token2));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        vm.expectRevert(TokenNotWhitelisted.selector);
        Vault.deposit(address(Token1), depositAmount);


    }
    function test_withdraw_success_execution() public {
        uint depositAmount = 10;

        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        Vault.deposit(address(Token1), depositAmount);
        vm.expectEmit(true, true, true, false);
        emit Withdraw(actor1, address(Token1), depositAmount);
        Vault.withdraw(address(Token1), depositAmount);
        

    }
    function test_withdraw_success_balances_updated_as_expected() public {
        uint depositAmount = 10;
        uint withdrawAmount = 5;

        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        Vault.deposit(address(Token1), depositAmount);
        Vault.withdraw(address(Token1), withdrawAmount);
        uint userVaultBalance = Vault.userBalance(actor1, address(Token1));
        assertEq(userVaultBalance, depositAmount - withdrawAmount);
    }
    function test_withdraw_revert_Paused() public {
        uint depositAmount = 10;
        Vault.whitelistToken(address(Token1));
        Vault.pauseContract();
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        vm.expectRevert(Paused.selector);
        Vault.deposit(address(Token1), depositAmount);


    }
    function test_withdraw_revert_AmountZero() public {
        uint depositAmount = 10;
        Vault.whitelistToken(address(Token1));
        vm.startPrank(actor1);
        Token1.approve(address(Vault), depositAmount);
        Vault.deposit(address(Token1), depositAmount);
        vm.expectRevert(AmountZero.selector);
        Vault.withdraw(address(Token1), 0);
        
    }

}
