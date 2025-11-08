#!/bin/bash
set -e

# Mise à jour du système
echo "Mise à jour du système..."
apt-get update
apt-get upgrade -y

# Installation des dépendances
echo "Installation des dépendances..."
apt-get install -y curl wget git

# Installation de K3s (Kubernetes léger)
echo "Installation de K3s..."
curl -sfL https://get.k3s.io | sh -

# Attendre que K3s démarre
echo "Attente du démarrage de K3s..."
sleep 60

# Configurer l'accès kubectl pour l'utilisateur ubuntu
echo "Configuration de kubectl..."
mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
chmod 600 /home/ubuntu/.kube/config

# Configurer l'alias kubectl pour l'utilisateur ubuntu
echo "alias kubectl='sudo kubectl'" >> /home/ubuntu/.bashrc

# Créer un namespace de démo
echo "Création du namespace demo..."
sudo kubectl create namespace demo --dry-run=client -o yaml | sudo kubectl apply -f -

# Déployer une app de test (nginx)
echo "Déploiement de nginx..."
sudo kubectl create deployment nginx --image=nginx:alpine --namespace=demo --dry-run=client -o yaml | sudo kubectl apply -f -
sudo kubectl expose deployment nginx --port=80 --type=NodePort --namespace=demo --dry-run=client -o yaml | sudo kubectl apply -f -

# Déployer une application de test supplémentaire
sudo kubectl create deployment hello-world --image=containous/whoami --namespace=demo --dry-run=client -o yaml | sudo kubectl apply -f -
sudo kubectl expose deployment hello-world --port=80 --type=NodePort --namespace=demo --dry-run=client -o yaml | sudo kubectl apply -f -

# Attendre que les pods soient prêts
echo "Attente du démarrage des pods..."
sleep 30

# Afficher les informations
echo "=== INFORMATIONS K3s ===" > /home/ubuntu/k3s-info.txt
echo "K3s installé avec succès!" >> /home/ubuntu/k3s-info.txt
echo "Adresse IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" >> /home/ubuntu/k3s-info.txt
echo "" >> /home/ubuntu/k3s-info.txt
echo "=== TOKEN K3s ===" >> /home/ubuntu/k3s-info.txt
sudo cat /var/lib/rancher/k3s/server/node-token >> /home/ubuntu/k3s-info.txt
echo "" >> /home/ubuntu/k3s-info.txt
echo "=== COMMANDES UTILES ===" >> /home/ubuntu/k3s-info.txt
echo "Vérifier les nodes: sudo kubectl get nodes" >> /home/ubuntu/k3s-info.txt
echo "Vérifier les pods: sudo kubectl get pods -A" >> /home/ubuntu/k3s-info.txt
echo "Services exposés: sudo kubectl get svc -A" >> /home/ubuntu/k3s-info.txt

# Afficher les informations de déploiement
echo "=== DÉPLOIEMENTS ===" >> /home/ubuntu/k3s-info.txt
sudo kubectl get nodes >> /home/ubuntu/k3s-info.txt
echo "" >> /home/ubuntu/k3s-info.txt
sudo kubectl get pods -A >> /home/ubuntu/k3s-info.txt
echo "" >> /home/ubuntu/k3s-info.txt
sudo kubectl get svc -A | grep -E "(nginx|hello-world)" >> /home/ubuntu/k3s-info.txt

# Changer les permissions du fichier info
chown ubuntu:ubuntu /home/ubuntu/k3s-info.txt
chmod 644 /home/ubuntu/k3s-info.txt

echo "Installation K3s terminée avec succès!"
