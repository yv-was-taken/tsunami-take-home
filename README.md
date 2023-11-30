# Tsunami Vault take home tests

### repo structure

-   vault source code found under `src/TsunamiVault.sol`
-   tests to be found under `test/TsunamiVault.t.sol`


### getting started

- clone the repo to your local machine

-   make sure latest version of foundry is installed:
    -   if foundry is already installed: `foundryup`
    -   if foundry is not installed: `curl -L https://foundry.paradigm.xyz | bash`
- once foundry is installed and updated to latest version... install dependencies with `foundry install`

### how to run tests

- run `forge test`

if you would like to inspect the stack traces of the contract through each respective contract call, can match tests with `forge test --match-test {function name}` and specific level of verbosity with `-vvvv`

ex: inspect stack traces for deposit(). `forge test --match-test test_deposit -vvvv`

the test function names are structured so you can target specific behaviour if needed. i.e. `forge test --match-test test_withdraw_revert` would target only instances where calling the withdraw function would be expected to revert. `forge test--match-test test_deposit_success` would target only instances where calling deposit() fn is expected to succeed. go nuts!


PS: if you are having trouble getting foundry to run please check the installation instructions found [here](https://book.getfoundry.sh/getting-started/installation) for further assistance 


