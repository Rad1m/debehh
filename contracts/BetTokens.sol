// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Functionality:
// Stake
// Unstake
// Winners

contract Lottery is Ownable {
    
    struct PlayersStruct {
        uint amount;
        string betOnThis;
        uint blockNumber;
    }
    mapping(address => PlayersStruct) public balances;
    
    address payable[] public players;
    address payable[] public winners;
    uint256 public entryFee;
    uint256 public betValue;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    } // enum states are represented by numbers 0,1,2,...

    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash;

    constructor() public {}

   function enterLottery(address _staker, uint256 _amount, string memory _betOnThis) public payable {
       require(lottery_state == LOTTERY_STATE.OPEN);
       require(_amount >= 50, "Minimum bet not reached");
       getEntranceFee(_amount);
       players.push(payable(_staker));
       balances[_staker].amount = _amount;
       balances[_staker].betOnThis = _betOnThis;
       balances[_staker].blockNumber = block.number;
       console.log("Sender address is %s :", msg.sender);
       console.log("Staker address is %s :", _staker);
       console.log("Staker amount is %s :", _amount);
       console.log("Players array size is %s :", players.length);
   }

   function getEntranceFee(uint256 _betAmount) public pure returns (uint256) {
       // do some rules to enter here
       uint256 minimumBet = _betAmount;
       return minimumBet;
   }

   function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

   function endLottery() public onlyOwner {
       lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
   }

   function closeLottery() public onlyOwner {
       lottery_state = LOTTERY_STATE.CLOSED;
   }

   function getWinners(address _staker) view public returns (uint) {
       console.log("Returning:", balances[_staker].amount);
       return balances[_staker].amount;
   }
}