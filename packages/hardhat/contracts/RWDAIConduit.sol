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

import "./interfaces/IArrangerConduit.sol";

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

contract RWDAIConduit is IArrangerConduit {
    // --- storage variables ---

    mapping(address => uint256) public wards;
    mapping(bytes32 => mapping(address => uint256)) public positions;

    // --- immutables ---

    RolesLike    private immutable allocatorRoles;
    RegistryLike private immutable allocatorRegistry;
    address public immutable manager; // will be the valut address like spark protocol

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
        require(allocatorRoles.canCall(ilk, msg.sender, address(this), msg.sig), "AllocatorConduitExample/ilk-not-authorized");
        _;
    }

    // --- constructor ---

    constructor(address roles_, address registry_) {
        allocatorRoles = RolesLike(roles_);
        allocatorRegistry = RegistryLike(registry_);
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

    function deposit(bytes32 ilk, address asset, uint256 amount) external ilkAuth(ilk) {
        address buffer = allocatorRegistry.buffers(ilk);
        BufferLike(buffer).approve(asset, address(this), amount);
        TokenLike(asset).transferFrom(buffer, manager, amount);
        positions[ilk][asset] += amount;
        emit Deposit(ilk, asset, buffer, amount);
    }

    function withdraw(bytes32 ilk, address asset, uint256 maxAmount) external ilkAuth(ilk) returns (uint256 amount) {
        uint256 balance = positions[ilk][asset];
        amount = balance < maxAmount ? balance : maxAmount;
        positions[ilk][asset] = balance - amount;
        address buffer = allocatorRegistry.buffers(ilk);
        TokenLike(asset).transferFrom(manager, buffer, amount);
        emit Withdraw(ilk, asset, buffer, amount);
    }

    /**
     *  @dev    Returns the arranger address.
     *  @return arranger_ The address of the arranger.
     */
    function arranger() external view returns (address arranger_){
        arranger_ = manager;
    }

    /**
     *  @dev    Returns the AllocationRegistry address.
     *  @return registry_ The address of the registry contract.
     */
    function registry() external view returns (address registry_){
        registry_ = address(allocatorRegistry);
    }

    /**
     *  @dev    Returns the roles address.
     *  @return roles_ The address of the roles.
     */
    function roles() external view returns (address roles_){
        roles_ = address(allocatorRoles);
    }

    /**
     *  @dev    Returns the total deposits for a given asset.
     *  @param  asset          The address of the asset.
     *  @return totalDeposits_ The total deposits held in the asset.
     */
    function totalDeposits(address asset) external view returns (uint256 totalDeposits_){
        totalDeposits_ = positions["ETH-A"][asset];
    }

    /**
     *  @dev    Returns the total requested funds for a given asset.
     *  @param  asset          The address of the asset.
     *  @return totalRequestedFunds_ The total requested funds held in the asset.
     */
    function totalRequestedFunds(address asset) external view returns (uint256 totalRequestedFunds_){
    }

    /**
     *  @dev    Returns the total amount that can be withdrawn for a given asset.
     *  @param  asset              The address of the asset.
     *  @return totalWithdrawableFunds_ The total amount that can be withdrawn from the asset.
     */
    function totalWithdrawableFunds(address asset) external view returns (uint256 totalWithdrawableFunds_){

    }

    /**
     *  @dev    Returns the total amount of cumulative withdrawals for a given asset.
     *  @param  asset             The address of the asset.
     *  @return totalWithdrawals_ The total amount that can be withdrawn from the asset.
     */
    function totalWithdrawals(address asset) external view returns (uint256 totalWithdrawals_){
        
    }

    /**
     *  @dev    Returns the aggregate deposits for a given ilk and asset.
     *  @param  ilk        The unique identifier for a particular ilk.
     *  @param  asset      The address of the asset.
     *  @return deposits_ The deposits for the given ilk and asset.
     */
    function deposits(bytes32 ilk, address asset) external view returns (uint256 deposits_){}

    /**
     *  @dev    Returns the aggregate requested funds for a given ilk and asset.
     *  @param  ilk             The unique identifier for a particular ilk.
     *  @param  asset           The address of the asset.
     *  @return requestedFunds_ The requested funds for the given ilk and asset.
     */
    function requestedFunds(bytes32 ilk, address asset)
        external view returns (uint256 requestedFunds_){}

    /**
     *  @dev    Returns the aggregate withdrawable funds for a given ilk and asset.
     *  @param  ilk           The unique identifier for a particular ilk.
     *  @param  asset         The address of the asset.
     *  @return withdrawableFunds_ The withdrawableFunds funds for the given ilk and asset.
     */
    function withdrawableFunds(bytes32 ilk, address asset)
        external view returns (uint256 withdrawableFunds_){}

    /**
     *  @dev    Returns the aggregate cumulative withdraws for a given ilk and asset.
     *  @param  ilk          The unique identifier for a particular ilk.
     *  @param  asset        The address of the asset.
     *  @return withdrawals_ The withdrawals funds for the given ilk and asset.
     */
    function withdrawals(bytes32 ilk, address asset) external view returns (uint256 withdrawals_){}

    /**********************************************************************************************/
    /*** Administrative Functions                                                               ***/
    /**********************************************************************************************/

    /**
     *  @dev   Function to set a value in the contract, called by the admin.
     *  @param what The identifier for the value to be set.
     *  @param data The value to be set.
     */
    function file(bytes32 what, address data) external{}

    /**********************************************************************************************/
    /*** Allocator Functions                                                                    ***/
    /**********************************************************************************************/

    /**
     *  @dev   Function to cancel a withdrawal request from a Arranger.
     *  @param fundRequestId The ID of the withdrawal request.
     */
    function cancelFundRequest(uint256 fundRequestId) external{}

    /**
     *  @dev    Function to initiate a withdrawal request from a Arranger.
     *  @param  ilk           The unique identifier for a particular ilk.
     *  @param  asset         The asset to withdraw.
     *  @param  amount        The amount of tokens to withdraw.
     *  @param  info          Arbitrary string to provide additional info to the Arranger.
     *  @return fundRequestId The ID of the withdrawal request.
     */
    function requestFunds(bytes32 ilk, address asset, uint256 amount, string memory info)
        external returns (uint256 fundRequestId){}

    /**********************************************************************************************/
    /*** Arranger Functions                                                                     ***/
    /**********************************************************************************************/

    /**
     * @notice Draw funds from the contract to the Arranger.
     * @dev    Only the Arranger is authorized to call this function.
     * @param  asset  The ERC20 token contract address from which funds are being drawn.
     * @param  amount The amount of tokens to be drawn.
     */
    function drawFunds(address asset, uint256 amount) external{}

    /**
     * @notice Return funds (principal only) from the Arranger back to the contract.
     * @dev    Only the Arranger is authorized to call this function.
     * @param  fundRequestId The ID of the withdrawal request.
     * @param  amount        The amount of tokens to be returned.
     */
    function returnFunds(uint256 fundRequestId, uint256 amount)
        external{}

    /**********************************************************************************************/
    /*** View Functions                                                                         ***/
    /**********************************************************************************************/

    /**
     *  @dev    Function to get the amount of funds that can be drawn by the Arranger.
     *  @param  asset          The asset to check.
     *  @return drawableFunds_ The amount of funds that can be drawn by the Arranger.
     */
    function drawableFunds(address asset) external view returns (uint256 drawableFunds_){}

    /**
     *  @dev    Returns a FundRequest struct at a given fundRequestId.
     *  @param  fundRequestId The id of the fund request.
     *  @return fundRequest   The FundRequest struct at the fundRequestId.
     */
    function getFundRequest(uint256 fundRequestId)
        external view returns (FundRequest memory fundRequest){}

    /**
     * @dev    Returns the length of the fundRequests array.
     * @return fundRequestsLength The length of the fundRequests array.
     */
    function getFundRequestsLength() external view returns (uint256 fundRequestsLength){}

    /**
     *  @dev    Function to check if a withdrawal request can be cancelled.
     *  @param  fundRequestId  The ID of the withdrawal request.
     *  @return isCancelable_  True if the withdrawal request can be cancelled, false otherwise.
     */
    function isCancelable(uint256 fundRequestId) external view returns (bool isCancelable_){}
}
