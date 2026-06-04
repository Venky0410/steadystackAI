#!/bin/bash
# ===== CloudShell Daily Startup =====

# Install Terraform
wget -q https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip -q terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.5.0_linux_amd64.zip

# Install Helm
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Connect to EKS
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name steadystackai-cluster 2>/dev/null || true

# Pull latest code
cd ~ && git clone https://github.com/Venky0410/JewelHub.git \
  2>/dev/null || (cd ~/JewelHub && git pull)
cd ~ && git clone https://github.com/Venky0410/steadystackAI.git \
  2>/dev/null || (cd ~/steadystackAI && git pull)

# Get all URLs
echo ""
echo "🔍 Checking service URLs..."
./get-urls.sh 2>/dev/null || true

echo ""
echo "✅ CloudShell ready!"