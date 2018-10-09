pragma solidity ^0.4.21;

import "giveth-common-contracts/contracts/Escapable.sol";
import './lib/BridgeInterface.sol';
import './lib/Pausable.sol';

contract CollectionBox is BridgeInterface, Escapable, Pausable {

    address bridgeAddress = 0xC59dCE5CCC065A4b51A2321F857466A25ca49B40;
    mapping(address => bool) tokenWhitelist;
    uint64 receiverId;
    uint transactionsCount = 0;
    event DonateAndCreateGiver(address giver, uint64 receiverId, address token, uint amount);


    struct transaction {
        address donator;
        address token;
        uint donation;
    }

    transaction[] public transactions;
 
    constructor (
        address _escapeHatchCaller,
        address _escapeHatchDestination,
        uint64 _receiverId
    ) Escapable (
        _escapeHatchCaller,
        _escapeHatchDestination
    ) public
    {
        receiverId = _receiverId;
        tokenWhitelist[0] = true; // enable eth transfers
    }
    
    function() payable external {

        require(msg.value > 0);
        
        transaction memory newTransaction = transaction({
            donator : msg.sender,
            donation : msg.value,
            token : 0x000
        });

        if(transactionsCount == transactions.length) {
            transactions.length += 1;
        }

        transactions[transactionsCount++] = newTransaction;
    }

    function donateERC20Tokens(address _token, uint _amount) whenNotPaused payable public {
        
        uint amount = _receiveDonation(_token, _amount);
         
        transaction memory newTransaction = transaction({
            donator : msg.sender,
            donation : amount,
            token : _token
        });
        
        if(transactionsCount == transactions.length) {
            transactions.length += 1;
        }

        transactions[transactionsCount++] = newTransaction;
    }
    
    /**
    * The `owner` can call this function to add/remove a token from the whitelist
    *
    * @param token The address of the token to update
    * @param accepted Wether or not to accept this token for donations
    */
    function whitelistToken(address token, bool accepted) whenNotPaused onlyOwner external {
        tokenWhitelist[token] = accepted;
    }

    function transferToBridge() external onlyOwner payable {

        for(uint i = 0; i < transactionsCount; i++) {
            donateAndCreateGiver(transactions[i].donator, receiverId, transactions[i].token, transactions[i].donation);
        
            if(transactions[i].token != 0x000) {
                ERC20(transactions[i].token).transferFrom(this, bridgeAddress, transactions[i].donation);
            } 
        }
        bridgeAddress.transfer(this.balance);
        clearTransactions();

    }

    function clearTransactions() internal {
        transactionsCount = 0;
    }

    function donateAndCreateGiver(address giver, uint64 _receiverId, address token, uint _amount) whenNotPaused private {
        require(giver != 0);
        require(_receiverId != 0);
        emit DonateAndCreateGiver(giver, _receiverId, token, _amount);
    }

   
    /**
    * @dev used to actually receive the donation. Will transfer the token to to this contract
    */
    function _receiveDonation(address token, uint _amount) internal returns(uint amount) {
        require(tokenWhitelist[token]);
        amount = _amount;

        // eth donation
        if (token == 0x000) {
            amount = msg.value;
        }

        require(amount > 0);

        if (token != 0) {
           require(ERC20(token).transferFrom(msg.sender, this, amount));
        }
    }
}
