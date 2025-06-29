// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

interface IFtsoRegistry {
    function getFtsoBySymbol(string calldata _symbol) external view returns (address);
}
