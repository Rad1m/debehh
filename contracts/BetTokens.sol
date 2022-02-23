// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

// Functionality:
// Stake
// Unstake
// Winners

contract Lottery is Ownable {
    address payable[] public players;
    address payable[] public recentWinner;
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

    constructor(uint256 _fee) public {fee = _fee;}

   function enterLottery(uint256 _betAmount) public payable {
       require(lottery_state == LOTTERY_STATE.OPEN);
       require(msg.value >= getEntranceFee(_betAmount), "Minimum bet not reached");

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

   function getWinners() public onlyOwner {

   }


}