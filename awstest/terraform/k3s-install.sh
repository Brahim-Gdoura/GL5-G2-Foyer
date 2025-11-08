#!/bin/bash
# k3s-install.sh
set -e

echo "🔄 Mise à jour du système..."
apt-get update
apt-get upgrade -y

echo "📦 Installation des dépendances..."
apt-get install -y curl wget

echo "🚀 Installation de K3s..."
curl -sfL https://get.k3s.io | sh -

echo "⏳ Attente du démarrage de K3s..."
sleep 30

echo "✅ K3s installé avec succès!"
sudo kubectl get nodes
