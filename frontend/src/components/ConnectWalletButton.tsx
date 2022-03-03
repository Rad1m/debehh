import React, { useEffect, useState } from "react";
import { MetaMaskInpageProvider } from "@metamask/providers";
import Button from "@mui/material/Button";
import Tooltip from "@mui/material/Tooltip";

declare var window: any;
const ethereum = window.ethereum as MetaMaskInpageProvider;

async function connectWallet() {
  await ethereum.request({ method: "eth_requestAccounts" });
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
