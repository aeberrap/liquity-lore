// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IPool.sol";


interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolLUSDDebtUpdated(uint _LUSDDebt);
    event DefaultPoolNEON_TOKENBalanceUpdated(uint _NEON_TOKEN);

    // --- Functions ---
    function sendNEON_TOKENToActivePool(uint _amount) external;
}
