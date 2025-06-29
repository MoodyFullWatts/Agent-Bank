// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IFtso {
    function getCurrentPrice(address _asset) external view returns (uint256, uint256);
    // Additional FTSO functions can be added as needed
}
