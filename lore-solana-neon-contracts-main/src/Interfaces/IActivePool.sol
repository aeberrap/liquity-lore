// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IPool.sol";


interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolLUSDDebtUpdated(uint _LUSDDebt);
    event ActivePoolNEON_TOKENBalanceUpdated(uint _NEON_TOKEN);

    // --- Functions ---
    function sendNEON_TOKEN(address _account, uint _amount) external;
}
