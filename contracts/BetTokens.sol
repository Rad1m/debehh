// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Functionality:
// Stake
// Unstake
// Winners

contract Lottery is Ownable {
    
    struct PlayersStruct {
        uint stakedAmount;
        string betOnThis;
        uint blockNumber;
    }
    // mapping players to know stake amount and what they bet on
    mapping(address => PlayersStruct) public balances;

    // mapping token address -> staker address -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    
    address payable[] public players; // list of all players
    address payable[] public winners; // list of winners
    uint256 public entryFee; // entry fee goes to team and treasury
    uint256 public winPrize; // prize for winners
    uint256 public totalValueLocked; // total valu elocked for all stakes and tokens
    address[] public allowedTokens; // only allowed tokens can be used for betting

    

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    } // enum states are represented by numbers 0,1,2,...

    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash;

    //constructor to know address of token for rewards
    constructor() public {
        
    }

   // stake tokens
   function enterLottery(address _staker, uint256 _amount, string memory _betOnThis) public payable {
       require(lottery_state == LOTTERY_STATE.OPEN);
       require(tokenIsAllowed(_token), "Token is currently not allowed");

       // get fee for the team
       entryFee = getEntranceFee(_amount);
       // stake the token here

       // add player to the array
       players.push(payable(_staker));

       // add player to the struct
       balances[_staker].stakedAmount += (_amount - entryFee);
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

   function tokenIsAllowed(address _token) public returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
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

       // calculate percentage of total pool
       uint256 shareOfPool = 100*balances[_staker].stakedAmount / totalValueLocked;

        console.log("Total Value Locked is %s :", totalValueLocked);
        console.log("Staked amount is %s :", balances[_staker].stakedAmount);
        console.log("shareOfPool is %s%:", shareOfPool);

        // pool prize is TVL but we have equal or less winners than total players
        // winPrize is TVL divided by number of winner multiplied by share of pool
       if (winners.length==1){
           winPrize =   ( totalValueLocked / winners.length); // only one winner, get entire pool
           console.log("Winner prize is 100% which is %s", winPrize );
       } else if (winners.length>1){
           winPrize =   ( totalValueLocked / winners.length) * shareOfPool / 100; // divide by 100 to get percentage
           console.log("Winner prize is %s% which is %s", shareOfPool, winPrize );
       }
       else {
           winPrize = 0;
       }
   }

   function mintAndBurnPrize(address _staker) public view returns(uint256 value){
       // assess if player is a winner
       // if winner, mint tokens
       // if loser, burn staked tokens
       bool winner = true;
       if (winner) {
           // mint tokens
           // return original stake

       } else {
           // burn tokens here
       }

   }

   function getUserTVL(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            totalValue =
                totalValue +
                getUserSingleTokenValue(
                    _user,
                    allowedTokens[allowedTokensIndex]
                );
        }
        return totalValue;
    }

   function getWinners(address _staker) public payable {
       // iterate through players and add winners
       // this could be gas expensive
       winners.push(payable(_staker));
   }
}