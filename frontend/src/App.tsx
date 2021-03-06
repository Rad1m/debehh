import React, { useState } from "react";
import { ethers } from "ethers";
// import Solidity contract artifacts
import TokenArtifact from "./contracts/DeBeToken.json";
import TokenAddress from "./contracts/token-address.json";
import LotteryArtifact from "./contracts/Lottery.json";
import LotteryAddress from "./contracts/contract-address.json";
// import ReactJS components
import ResponsiveAppBar from "./components/ResponsiveAppBar";

// This is the Hardhat Network id, you might change it in the hardhat.config.js.
const HARDHAT_NETWORK_ID = "42";

// This is an error code that indicates that the user canceled a transaction
const ERROR_CODE_TX_REJECTED_BY_USER = 4001;

interface IProps {}

interface IState {}

export class App extends React.Component<IProps, IState> {
  constructor(props: IProps) {
    super(props);
  }

  render() {
    return (
      <div>
        <ResponsiveAppBar />
      </div>
    );
  }
}
