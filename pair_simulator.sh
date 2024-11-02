#!/bin/bash

# This script pairs an iOS simulator with a watchOS simulator.
# Usage: ./pair_simulator.sh <WATCH_UDID> <IPHONE_UDID>
# Example: ./pair_simulator.sh ABCD1234 EF5678GH
#
# To make this script executable:
# 1. Open Terminal and navigate to the directory where you saved this script.
# 2. Run the following command to make the script executable:
#
#    chmod +x pair_simulator.sh
#
# 3. You can then run the script with ./pair_simulator.sh WATCH_UDID IPHONE_UDID
#
# Parameters:
#   WATCH_UDID  - The unique device identifier for the watchOS simulator.
#   IPHONE_UDID - The unique device identifier for the iOS simulator.
#
# To get a list of UDID values for available simulators, run the following 
# command:
#
# xcrun simctl list devices

# Check if both parameters (WATCH_UDID and IPHONE_UDID) are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <WATCH_UDID> <IPHONE_UDID>"
  echo "Example: $0 ABCD1234 EF5678GH"
  exit 1
fi

# Assign command-line arguments to variables
WATCH_UDID="$1"
IPHONE_UDID="$2"

# Run the pairing command
echo "Pairing iOS simulator (UDID: $IPHONE_UDID) with watchOS simulator (UDID: $WATCH_UDID)..."
xcrun simctl pair "$WATCH_UDID" "$IPHONE_UDID"

# Check if the command succeeded
if [ $? -eq 0 ]; then
  echo "Pairing successful!"
else
  echo "Pairing failed. Please check the UDIDs and try again."
fi