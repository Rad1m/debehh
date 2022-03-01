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

       address staker = msg.sender;
       uint amount = msg.value;

       // get fee for the team
       uint fee = getEntranceFee(amount);
       uint stakeAmount = amount - fee;
       token.transferFrom(staker, address(this), fee); // here should be treasury wallet

       // stake the token here
       token.transferFrom(staker, address(this), stakeAmount);

       // add player to the array
       playerList.push(payable(staker));

       // add player to the struct
       balances[staker].stakedAmount += stakeAmount;
       balances[staker].betOnThis = _betOnThis;
       balances[staker].blockNumber = block.number;
       balances[staker].winner = false;
       balances[staker].rewarded = false;

       // update total value locked
       totalValueLocked += stakeAmount;
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

   // this will be run every time a user will claim their reward
   function calculatePrize() public view returns(uint256 winAmount){
       // get player's address
       address staker = msg.sender;

        // The number of winners will be less or equal to number of players
        // the winners will share the prize among themselves
        // players who didn't win will lose their stake
        // the IF condirions are used to save on gas
       if (winnerList.length == 1){
           winAmount =   totalValueLocked; // only one winner ==> gets entire pool
       } else if (winnerList.length > 1){
           // players with higher bets will get higher (weighted) rewards
           uint weight = balances[staker].stakedAmount * 10000 /winPool;
           winAmount = ((totalValueLocked - winPool) * weight)/10000;
           winAmount = winAmount + balances[staker].stakedAmount;
       }
       else {
           // if nobody has won, then there is no rewards
           winAmount = 0;

           // transfer tokens to treasury
        //    token.transfer(treaury, totalValueLocked);
       }
       return winAmount;
   }

    // THIS IS NOT FINISHED
   function mintAndBurnPrize(bool winner) public {
       // assess if player is a winner
       // if winner, mint tokens
       // if loser, burn staked tokens
       
       // get staked amount
       address staker = msg.sender;
       uint amount = getUserTVL(staker);
       require(balances[staker].rewarded == false, "Reward already paid out");

       if (winner) {
           // return original stake plus mint same amount
           // this way user gets 2x reward
           console.log("mintAndBurnPrize amount is %",amount );
           token.transfer(staker, amount);
           // remove player from mapping
           balances[staker].stakedAmount = 0;
           balances[staker].rewarded = true;
       } else {
           // burn tokens here
           token.burnFrom(staker, amount);
           balances[staker].stakedAmount = 0;
           balances[staker].rewarded = true;
       }

   }

    // get how much money user staked
    function getUserTVL(address _user) public view returns(uint){
        uint totalValue = 0;
        totalValue = balances[_user].stakedAmount;
        return totalValue;
    }

    // check how many winners we have
    // winners wil split the prize among themnselves
   function getWinners(string memory _result) public onlyOwner {
       // iterate through players and add winners to array
       // this is gas expensive
       require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "Lottery needs to finish first");
       for (uint i=0; i<playerList.length; i++) {

           // compare strings
           if(keccak256(abi.encodePacked(balances[playerList[i]].betOnThis)) == keccak256(abi.encodePacked(_result)))
           {
               balances[playerList[i]].winner = true;
               winnerList.push(payable(playerList[i]));
           } else {
               balances[playerList[i]].winner = false;
           }
        }
        getWinPool(); // get much staked there is among winners
   }

   function getWinPool () public onlyOwner {
       require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "Lottery needs to finish first");
       for (uint i=0; i<winnerList.length; i++) {
            winPool += balances[winnerList[i]].stakedAmount;
        }
        closeLottery(); // close lottery, rewards can be paid out
   }
}