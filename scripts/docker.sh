#!/bin/bash

set -e

echo "==> Configuring Docker daemon..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
    "log-driver": "json-file",
    "log-opts": { "max-size": "10m", "max-file": "5" },
    "dns": ["172.17.0.1"],
    "bip": "172.17.0.1/16"
}
EOF

echo "==> Setting up systemd resolved DNS for Docker..."
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e '[Resolve]\nDNSStubListenerExtra=172.17.0.1' | sudo tee /etc/systemd/resolved.conf.d/20-docker-dns.conf >/dev/null
sudo systemctl restart systemd-resolved

echo "==> Enabling Docker service..."
sudo systemctl enable docker

echo "==> Adding user '$USER' to docker group..."
sudo usermod -aG docker ${USER}

echo "==> Creating systemd override for Docker boot..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

echo "==> Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "==> Restarting Docker service..."
sudo systemctl restart docker

