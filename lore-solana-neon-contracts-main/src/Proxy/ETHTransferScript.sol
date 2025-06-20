// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;


contract NEON_TOKENTransferScript {
    function transferNEON_TOKEN(address _recipient, uint256 _amount) external returns (bool) {
        (bool success, ) = _recipient.call{value: _amount}("");
        return success;
    }
}
