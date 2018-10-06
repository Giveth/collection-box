pragma solidity ^0.4.21;

import './GivethBridge.sol';

contract CollectionBox  is GivethBridge{
    
    address DACAddress = 0xC59dCE5CCC065A4b51A2321F857466A25ca49B40;
    
    struct donatorsInfo {
        uint donation;
        bool exists;
    }
    
    mapping (address => donatorsInfo) donators;
    
    function CollectionBox (
        address _escapeHatchCaller,
        address _escapeHatchDestination,
        uint _absoluteMinTimeLock,
        uint _timeLock,
        address _securityGuard,
        uint _maxSecurityGuardDelay
    ) GivethBridge(
        _escapeHatchCaller,
        _escapeHatchDestination,
        _absoluteMinTimeLock,
        _timeLock,
        _securityGuard,
        _maxSecurityGuardDelay
    )public 
    {
    }
    
    function donate()  payable external {
        
        if(donators[msg.sender].exists)
            donators[msg.sender].donation = donators[msg.sender].donation + msg.value;
        else
             donators[msg.sender].donation =  msg.value;
        
        DACAddress.transfer(msg.value);
    }
    
    function getDonatorInfo(address donator) public view returns(uint) {
        return donators[donator].donation;
    }

}
