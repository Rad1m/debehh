import React, { useEffect, useState } from "react";
import { MetaMaskInpageProvider } from "@metamask/providers";
import Button from "@mui/material/Button";
import Tooltip from "@mui/material/Tooltip";
import TokenArtifact from "../contracts/DeBeToken.json";
import TokenAddress from "../contracts/token-address.json";
import { ethers } from "ethers";

declare var window: any;
const ethereum = window.ethereum as MetaMaskInpageProvider;

async function connectWallet() {
  await ethereum.request({ method: "eth_requestAccounts" });
}

async function execute() {
  const contractAddress = TokenAddress.Token;
  const abi = TokenArtifact.abi;
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const contract = new ethers.Contract(contractAddress, abi, signer);
  await contract.balanceOf(signer);
}

export function ConnectWalletButton() {
  return (
    <>
      <Tooltip title="This action will connect your Wallet">
        <Button
          variant="contained"
          color="secondary"
          sx={{ mx: "auto", width: 200, p: 1, m: 1 }}
          onClick={() => connectWallet()}
        >
          Connect
        </Button>
      </Tooltip>
    </>
  );
}
