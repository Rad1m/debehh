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
    uint256 public winPrize;
    uint256 public totalValueLocked;

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

       // get fee for the team
       entryFee = getEntranceFee(_amount);
       // stake the token here

       // add player to the array
       players.push(payable(_staker));

       // add player to the struct
       balances[_staker].amount = _amount;
       balances[_staker].betOnThis = _betOnThis;
       balances[_staker].blockNumber = block.number;

       // update total value locked
       totalValueLocked += (_amount-entryFee);

       console.log("Total Value Locked is %s :", totalValueLocked);
   }

   function getEntranceFee(uint256 _betAmount) public pure returns(uint entryFee){
       // do some rules to enter here
       uint256 minimumBet = 50;
       require(_betAmount >= minimumBet, "Minimum bet not reached");
       entryFee = _betAmount * 5 / 100; // 5%
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

   function calculatePrize(address _staker) public view returns(uint256 winPrize){
       // the size of prize is proportional to the size of stake
       // change logic here
       winPrize = totalValueLocked/winners.length;
   }

   function getWinners(address _staker) public payable {
       // iterate through players and add winners
       // this could be gas expensive
       winners.push(payable(_staker));
   }
}