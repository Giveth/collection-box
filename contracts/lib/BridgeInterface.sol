pragma solidity ^0.4.21;

contract BridgeInterface {

    /// @dev Donates and Creates Giver
    function donateAndCreateGiver(address giver, uint64 receiverId);
    
}
