# Tsunami Vault take home tests

### repo structure

-   vault source code found under `src/TsunamiVault.sol`
-   tests to be found under `test/TsunamiVault.t.sol`

### how to run tests

-   make sure latest version of foundry is installed:
    -   if foundry is already installed: `foundryup`
    -   if foundry is not installed:

        ```
        curl -L https://foundry.paradigm.xyz | bash
    
        ```
- once foundry is installed...
    ```
    forge test

    ```

if you would like to inspect the stack traces of the contract through each respective contract call, can match tests with `forge test --match-test {function name}` and specific level of verbosity with `-vvvv`

ex: inspect stack traces for deposit(). `forge test --match-test test_deposit -vvvv`


PS: if you are having trouble getting foundry to run please check the installation instructions found [here](https://book.getfoundry.sh/getting-started/installation) for further assistance 


that should be it, thanks for the opportunity!
