#!/bin/bash

echo "=== Azure VM Terraform Deployment ==="
echo

# Initialize and apply Terraform
terraform init -upgrade 
terraform plan 
terraform apply -auto-approve

echo
echo "=== Deployment Complete ==="
echo

# Display connection information
echo "SSH connection details:"
echo "Public IP: $(terraform output -raw public_ip_address)"
echo "SSH Command: $(terraform output -raw ssh_connection_command)"
echo "Private Key: $(terraform output -raw private_key_path)"
echo "Public Key: $(terraform output -raw public_key_path)"
echo
echo "To connect to your VM, run:"
echo "$(terraform output -raw ssh_connection_command)"
echo
echo "Note: The private key file has been saved locally with correct permissions (600)."
