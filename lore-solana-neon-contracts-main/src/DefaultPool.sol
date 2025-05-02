// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import './Interfaces/IDefaultPool.sol';
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";

/*
 * The Default Pool holds the NEON_TOKEN and LUSD debt (but not LUSD tokens) from liquidations that have been redistributed
 * to active troves but not yet "applied", i.e. not yet recorded on a recipient active trove's struct.
 *
 * When a trove makes an operation that applies its pending NEON_TOKEN and LUSD debt, its pending NEON_TOKEN and LUSD debt is moved
 * from the Default Pool to the Active Pool.
 */
contract DefaultPool is Ownable, CheckContract, IDefaultPool {
    using SafeMath for uint256;

    string constant public NAME = "DefaultPool";

    address public troveManagerAddress;
    address public activePoolAddress;
    uint256 internal NEON_TOKEN;  // deposited NEON_TOKEN tracker
    uint256 internal LUSDDebt;  // debt

    // --- Events ---
    // TroveManagerAddressChanged, DefaultPoolLUSDDebtUpdated, DefaultPoolNEON_TOKENBalanceUpdated are inherited from IDefaultPool

    // --- Dependency setters ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress
    )
        external
        onlyOwner
    {
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);

        troveManagerAddress = _troveManagerAddress;
        activePoolAddress = _activePoolAddress;

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);

        _renounceOwnership();
    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the NEON_TOKEN state variable.
    *
    * Not necessarily equal to the the contract's raw NEON_TOKEN balance - ore_tokener can be forcibly sent to contracts.
    */
    function getNEON_TOKEN() external view override returns (uint) {
        return NEON_TOKEN;
    }

    function getLUSDDebt() external view override returns (uint) {
        return LUSDDebt;
    }

    // --- Pool functionality ---

    function sendNEON_TOKENToActivePool(uint _amount) external override {
        _requireCallerIsTroveManager();
        address activePool = activePoolAddress; // cache to save an SLOAD
        NEON_TOKEN = NEON_TOKEN - _amount; // Using '-' instead of sub
        emit DefaultPoolNEON_TOKENBalanceUpdated(NEON_TOKEN);
        emit EtherSent(activePool, _amount);

        (bool success, ) = activePool.call{ value: _amount }("");
        require(success, "DefaultPool: sending NEON_TOKEN failed");
    }

    function increaseLUSDDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        LUSDDebt = LUSDDebt + _amount; // Using '+' instead of add
        emit DefaultPoolLUSDDebtUpdated(LUSDDebt);
    }

    function decreaseLUSDDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        LUSDDebt = LUSDDebt - _amount; // Using '-' instead of sub
        emit DefaultPoolLUSDDebtUpdated(LUSDDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == activePoolAddress, "DefaultPool: Caller is not the ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == troveManagerAddress, "DefaultPool: Caller is not the TroveManager");
    }

    // --- Fallback function ---

    receive() external payable {
        _requireCallerIsActivePool();
        NEON_TOKEN = NEON_TOKEN + msg.value; // Using '+' instead of add
        emit DefaultPoolNEON_TOKENBalanceUpdated(NEON_TOKEN);
    }
}
