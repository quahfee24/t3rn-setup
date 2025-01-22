#!/bin/bash

# t3rn Executor Setup Script for Ubuntu

echo "Starting t3rn Executor setup..."

# Step 1: Clean up old files
echo "Cleaning up old setup files..."
rm -rf ~/t3rn

# Step 2: Create t3rn directory
echo "Creating new directory for t3rn Executor..."
mkdir ~/t3rn
cd ~/t3rn || exit

# Step 3: Download the latest release
echo "Downloading the latest t3rn Executor release..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
wget https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/executor-linux-$LATEST_VERSION.tar.gz

# Step 4: Extract the archive
echo "Extracting the downloaded archive..."
tar -xzf executor-linux-*.tar.gz

# Step 5: Navigate to the binary location
cd executor/executor/bin || exit

# Step 6: Prompt for private key
echo "Please enter your private key:"
read -s PRIVATE_KEY_LOCAL

# Step 7: Configure environment variables
echo "Configuring environment variables..."
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true

# Step 8: Start the executor
echo "Starting the t3rn Executor..."
./executor

# Step 9: Success message
echo "t3rn Executor setup is complete and running!"
