// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Functionality:
// Stake
// Unstake
// Winners

contract Lottery is Ownable {
    mapping(address => uint) public balances;
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

   function enterLottery(address _staker, uint256 _amount) public payable {
       require(lottery_state == LOTTERY_STATE.OPEN);
       require(_amount >= 50, "Minimum bet not reached");
       getEntranceFee(_amount);
       players.push(payable(_staker));
       balances[_staker] = _amount;
       console.log("Sender address is %s :", msg.sender);
       console.log("Staker address is %s :", _staker);
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
       lottery_state = LOTTERY_STATE.CLOSED;
   }
}