// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./TreasuryBond.sol";

/**
 * @title A contract that holds treasurey bonds and pays interest payments to its invester.
 *
 */

contract TreasuryVault is ERC165, Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    using Address for address payable; // prettier-ignore

    //  Security token which represents the real world security for this usecase
    TreasuryBond public rwaSecurity;

    // the address of the treasurey contract which the security asset is purchased from
    address public immutable rwaSecurityAddress;

    // the address of the stable coin in which devidend is paid to this holder
    IERC20 public daiToken;
    
    struct account {
        uint256 balance;
        bool exists;
    }

    // mapping that holds total eth lent to this contract from different MakerSubDao
    mapping(address => account) public investers;


    // list of lenders
    address[] lenders;

    bool public isThresholdAmountReached = false;

    // threshold amount should be higher then cost of treasury to account for gas fees, 
    // for this test we can say two times the amount
    uint256 public thresholdAmount;

    uint256 ethBalance;
    

    /**
     * @dev Emitted when `amount` of stable coin received as dividend`.
     */
    event DividendReceived(address indexed operator, address indexed sender, uint256 amount);

   
    event LogTreasuryBondReceived();


    event LogTreasuryMaturity();


    /**
     * @param _rwaSecurityAddress address of the security contract
     * @param _dividendCurrency address of the stable coin / cbdc in which dividend is paid
     * @param _thresholdAmount thresholdAmount required to buy the security
     */
    constructor(address _rwaSecurityAddress, address _dividendCurrency, uint256 _thresholdAmount) {
        rwaSecurityAddress = _rwaSecurityAddress;
        rwaSecurity = TreasuryBond(_rwaSecurityAddress);
        daiToken =  IERC20(_dividendCurrency);
        thresholdAmount = _thresholdAmount;
    }

    /**
     * @notice send ETH to trigger minting of mithril tokens.
     *         amount of mithril to be minted is controled by the state of linear bonding curve at any given time
     *
     */
    receive() external payable {
        // increament pool balance
        require(msg.value > 0, "FORBIDDEN: only nonzero eth values are accepted");
        ethBalance += msg.value;
        if(!isThresholdReached())
        {
            if(ethBalance >= thresholdAmount) {

                updateAccountBalance(msg.sender,msg.value);
                
                rwaSecurity.BuyTreasuryBond{value: 2 wei}();
            }
            updateAccountBalance(msg.sender,msg.value);
        }
        else {
            refundEth(msg.value);
        }
    }

    // function onTransferReceived(
    //     address spender,
    //     address sender,
    //     uint256 amount,
    //     bytes memory data
    // ) public override returns (bytes4) {
    //     require(_msgSender() == rwaSecurityAddress, "FORBIDDEN: mithrilToken is not the message sender");

    //     emit LogTreasuryBondReceived();

    //     uint256 reward = getBurnReward(amount);
    //     calculateShareOfInvesters(payable(sender), amount, reward);

    //     return IERC1363Receiver.onTransferReceived.selector;
    // }

    function withDrawDividends() external nonReentrant {
        require(investers[msg.sender].exists, "FORBIDDEN: only investers can receive devidends");
        uint share = calculateInvesterShare(msg.sender);
        require(share <= daiToken.balanceOf(address(this)));
        bool success = daiToken.transfer(msg.sender, share);
    }

    // TODO: fix this by adding fixed point airthmatic calculations, and then using formula 
    // investerShare = investment / totalBalance
    function calculateInvesterShare(address invester) public view returns(uint256) {
        if(ethBalance == investers[invester].balance) {
            return investers[invester].balance;
        }
        // sudo calculation to get around using fixed point airtmatic, due to time constrainet
        uint256 investerShare = ethBalance - investers[invester].balance; 
        return investerShare;
    }

     // verifies that threshold amount required to buy the treasury has not already been reached
    function isThresholdReached() internal view returns(bool) {
        if (address(this).balance >= thresholdAmount) {
            return true;
        }
        return false;
    }

    function refundEth(uint256 _refundAmount) internal nonReentrant {
        address payable refundAddress = payable(msg.sender);
        refundAddress.sendValue(_refundAmount);
    }

    function updateAccountBalance(address _from, uint256 _amount) internal nonReentrant {
        if(!investers[_from].exists) {
            lenders.push(_from);
            investers[_from].balance += _amount;
        }
        else {
            investers[_from].balance += _amount;
        }
    }

}