// SPDX-FileCopyrightText: © 2023 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.16;

import "./interfaces/IAllocatorConduit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface RolesLike {
    function canCall(bytes32, address, address, bytes4) external view returns (bool);
}

interface RegistryLike {
    function buffers(bytes32) external view returns (address);
}

interface BufferLike {
    function approve(address, address, uint256) external;
}

interface TokenLike {
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external;
}

contract AllocatorConduitExample is IAllocatorConduit {
    // --- storage variables ---

    mapping(address => uint256) public wards;
    mapping(bytes32 => mapping(address => uint256)) public positions;

    // --- immutables ---

    RolesLike    public immutable roles;
    RegistryLike public immutable registry;
    address public immutable admin;
    address public immutable manager;

    // --- events ---

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event SetRoles(bytes32 indexed ilk, address roles_);

    // --- modifiers ---

    modifier auth() {
        require(wards[msg.sender] == 1, "AllocatorBuffer/not-authorized");
        _;
    }

    modifier ilkAuth(bytes32 ilk) {
        require(roles.canCall(ilk, msg.sender, address(this), msg.sig), "AllocatorConduitExample/ilk-not-authorized");
        _;
    }

    // --- constructor ---

    constructor(address roles_, address registry_, address manager_) {
        roles = RolesLike(roles_);
        registry = RegistryLike(registry_);
        admin = msg.sender;
        manager = manager_;
    }

    // --- getters ---

    function maxDeposit(bytes32 ilk, address asset) external pure returns (uint256 maxDeposit_) {
        ilk;asset;
        maxDeposit_ = type(uint256).max;
    }

    function maxWithdraw(bytes32 ilk, address asset) external view returns (uint256 maxWithdraw_) {
        maxWithdraw_ = positions[ilk][asset];
    }

    // --- admininstration ---

    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }

    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    // --- functions ---

    function deposit(bytes32 ilk, address asset, uint256 amount) external {
        positions[ilk][asset] += amount;
        TokenLike(asset).transferFrom(admin, manager, amount);
        emit Deposit(ilk, asset, admin, amount);
    }

    function withdraw(bytes32 ilk, address asset, uint256 maxAmount) external returns (uint256 amount) {
        uint256 balance = positions[ilk][asset];
        amount = balance < maxAmount ? balance : maxAmount;
        positions[ilk][asset] = balance - amount;
        TokenLike(asset).transferFrom(manager, admin, amount);
        emit Withdraw(ilk, asset, admin, amount);
    }
}
