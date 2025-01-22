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
echo "Please enter your private key (this will not be displayed):"
read -s PRIVATE_KEY_LOCAL

# Step 7: Prompt for Alchemy API Key
echo "Do you have an Alchemy API key for Sepolia? (y/n)"
read -r HAS_ALCHEMY_KEY

if [ "$HAS_ALCHEMY_KEY" == "y" ]; then
    echo "Please enter your Alchemy API key for Sepolia:"
    read -r ALCHEMY_API_KEY
    echo "Configuring Alchemy RPC URLs for Sepolia using your API key..."
    export RPC_ENDPOINTS_ARBT="https://arb-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY"
    export RPC_ENDPOINTS_BASE="https://base-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY"
    export RPC_ENDPOINTS_OPTIMISM="https://opt-sepolia.g.alchemy.com/v2/$ALCHEMY_API_KEY"
else
    echo "No Alchemy API key provided. Default Sepolia RPC URLs will be used."
fi

# Step 8: Ask user if they want to process orders via the API
echo "Do you want to process orders using the t3rn API? (y/n)"
read -r USE_API

if [ "$USE_API" == "y" ]; then
    echo "Using API for processing orders."
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
else
    echo "Processing orders via RPC."
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
fi

# Step 9: Configure environment variables
echo "Configuring environment variables..."
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l1rn'
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL

# Step 10: Ask user if they want to run in the background with screen
echo "Do you want to run the t3rn Executor in the background using screen? (y/n)"
read -r RUN_BACKGROUND

if [ "$RUN_BACKGROUND" == "y" ]; then
    # Ensure screen is installed
    echo "Installing screen if not already installed..."
    sudo apt-get install -y screen

    # Start the process in a screen session
    echo "Starting the t3rn Executor in a screen session..."
    screen -dmS t3rn-executor ./executor
    echo "The t3rn Executor is running in the background using screen."
    echo "To reattach to the screen session, use the command:"
    echo "    screen -r t3rn-executor"
else
    # Run normally in the foreground
    echo "Starting the t3rn Executor in the foreground..."
    ./executor
fi

# Step 11: Success message
echo "t3rn Executor setup is complete!"

