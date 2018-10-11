pragma solidity ^0.4.21;

contract BridgeInterface {

    /// @dev Donates and Creates Giver
  function donateETHAndCreateGiver(address giver, uint64 receiverId, address token, uint amount) private;
    
}
