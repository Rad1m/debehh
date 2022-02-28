// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DeBeToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// Functionality:
// Stake
// Unstake
// Winners

contract Lottery is Ownable {

    DeBeToken token;

    constructor(DeBeToken _token) public {
        token = _token;
    }
    
    struct PlayersStruct {
        uint stakedAmount;
        string betOnThis;
        bool winner;
        bool rewarded;
        uint blockNumber;
    }
    // mapping players to know stake amount and what they bet on
    mapping(address => PlayersStruct) public balances;

    // mapping token address -> staker address -> amount
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    
    address payable[] public playerList; // list of all players
    address payable[] public winnerList; // list of winners
    uint256 public winPool; // prize for winners
    uint256 public totalValueLocked; // total valu elocked for all stakes and tokens
    address[] public allowedTokens; // only allowed tokens can be used for betting

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    } // enum states are represented by numbers 0,1,2,...

    LOTTERY_STATE public lottery_state;

   // staking tokens means entering the lottery, user can unstake their tokens for as long as the match has not started yet
   function enterLottery(string memory _betOnThis) public payable {
       require(lottery_state == LOTTERY_STATE.OPEN);
       //require(tokenIsAllowed(_token), "Token is currently not allowed");

       address _staker = msg.sender;
       uint _amount = msg.value;

       console.log("Value sent %s from %s", _amount, _staker);

       // get fee for the team
       uint fee = getEntranceFee(_amount);
       uint stakeAmount = _amount - fee;
       token.transferFrom(_staker, address(this), fee); // here should be treasury wallet

       // stake the token here
       token.transferFrom(_staker, address(this), stakeAmount);

       // add player to the array
       playerList.push(payable(_staker));

       // add player to the struct
       balances[_staker].stakedAmount += stakeAmount;
       balances[_staker].betOnThis = _betOnThis;
       balances[_staker].blockNumber = block.number;
       balances[_staker].winner = false;
       balances[_staker].rewarded = false;

       // update total value locked
       totalValueLocked += stakeAmount;

       console.log("Total Value Locked is %s :", totalValueLocked);
   }

   function getEntranceFee(uint256 _betAmount) public pure returns(uint entryFee){
       // do some rules to enter here
       uint minimumBet = 50;
       require(_betAmount >= minimumBet, "Minimum bet not reached");
       return entryFee = _betAmount * 5 / 100; // 5%
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

   function calculatePrize() public view returns(uint256 winAmount){
       // the size of prize is proportional to the size of stake
       // change logic here
       address staker = msg.sender;

       // calculate percentage of total pool
        console.log("Total Value Locked is %s :", totalValueLocked);
        console.log("Player's staked amount is %s :", balances[staker].stakedAmount);

        // pool prize is TVL but we have equal or less winners than total players
       if (winnerList.length == 1){
           winAmount =   totalValueLocked; // only one winner, get entire pool
           console.log("Winner prize is 100% which is %s", winAmount);
       } else if (winnerList.length > 1){
           uint weight = balances[staker].stakedAmount * 10000 /winPool;
           winAmount = ((totalValueLocked - winPool) * weight)/10000;
           winAmount = winAmount + balances[staker].stakedAmount;
           console.log("Winner prize is %s% which is %s", weight, winAmount );
       }
       else {
           winAmount = 0;
       }
       console.log("Retrun winAmount %s", winAmount );
       return winAmount;
   }

    // THIS IS NOT FINISHED
   function mintAndBurnPrize(bool winner) public {
       // assess if player is a winner
       // if winner, mint tokens
       // if loser, burn staked tokens
       
       // get staked amount
       address _staker = msg.sender;
       uint amount = getUserTVL(_staker);
       require(balances[_staker].rewarded == false, "Reward already paid out");

       if (winner) {
           // return original stake plus mint same amount
           // this way user gets 2x reward
           console.log("mintAndBurnPrize amount is %",amount );
           token.transfer(_staker, amount);
           // remove player from mapping
           balances[_staker].stakedAmount = 0;
           balances[_staker].rewarded = true;
       } else {
           // burn tokens here
           token.burnFrom(_staker, amount);
           balances[_staker].stakedAmount = 0;
           balances[_staker].rewarded = true;
       }

   }

    function getUserTVL(address _user) public view returns(uint){
        uint totalValue = 0;
        totalValue = balances[_user].stakedAmount;
        return totalValue;
    }

    // THIS IS HELPER FUNCTION
    // NOT IMPLEMENTED
   function getWinners(address _staker) public payable {
       // iterate through players and add winners
       // this could be gas expensive
       winnerList.push(payable(_staker));
   }

   function getWinPool () public {
       for (uint i=0; i<winnerList.length; i++) {
            winPool += balances[winnerList[i]].stakedAmount;
        }
   }
}