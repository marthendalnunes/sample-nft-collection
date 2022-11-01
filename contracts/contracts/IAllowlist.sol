// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAllowlist {
  function whitelistedAddresses(address) external view returns (bool);
}