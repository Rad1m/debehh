import React, { useEffect, useState } from "react";
import Button from "@mui/material/Button";
import Tooltip from "@mui/material/Tooltip";

export function ConnectWalletButton() {
  return (
    <>
      <Tooltip title="This action will connect your Wallet">
        <Button
          variant="contained"
          color="secondary"
          sx={{ mx: "auto", width: 200, p: 1, m: 1 }}
        >
          Connect
        </Button>
      </Tooltip>
      {/* Disconnect metamsak */}
    </>
  );
}
