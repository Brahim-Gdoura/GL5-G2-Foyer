#!/bin/bash

# Deploy Foyer App to K3s Cluster
# Usage: ./deploy-to-cluster.sh <public-ip> <path-to-private-key>

set -e

PUBLIC_IP=${1:-"107.23.80.88"}
PRIVATE_KEY=${2:-"/home/ahmad/my-key-pair.pem"}

echo "=== Deploying Foyer App to K3s Cluster ==="
echo "Public IP: $PUBLIC_IP"
echo "Private Key: $PRIVATE_KEY"
echo ""

# Check if private key exists
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "❌ Error: Private key not found at $PRIVATE_KEY"
    echo ""
    echo "To get the private key from Jenkins:"
    echo "1. Go to Jenkins workspace: /var/jenkins_home/workspace/aws/aws/terraform/"
    echo "2. Copy my-key-pair.pem to your local machine"
    echo ""
    echo "Or run this from Jenkins:"
    echo "  docker cp jenkins:/var/jenkins_home/workspace/aws/aws/terraform/my-key-pair.pem ."
    exit 1
fi

chmod 400 "$PRIVATE_KEY"

echo "Step 1: Fixing kubeconfig permissions and checking K3s status..."
ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP << 'EOF'
    # Fix kubeconfig permissions
    echo "Setting up kubeconfig..."
    mkdir -p ~/.kube
    sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config 2>/dev/null || {
        echo "Copying kubeconfig with sudo..."
        sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k3s-config
        sudo chown ubuntu:ubuntu /tmp/k3s-config
        mv /tmp/k3s-config ~/.kube/config
    }
    chmod 600 ~/.kube/config
    
    # Set environment variable
    export KUBECONFIG=~/.kube/config
    
    # Check K3s status
    echo "Checking cluster status..."
    kubectl get nodes
EOF

echo ""
echo "Step 2: Copying k8s-deployment.yml to server..."
scp -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no k8s-deployment.yml ubuntu@$PUBLIC_IP:~/

echo ""
echo "Step 3: Deploying application..."
ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP << 'EOF'
    # Ensure kubeconfig is set
    export KUBECONFIG=~/.kube/config
    
    # Apply the deployment
    kubectl apply -f k8s-deployment.yml
    
    echo ""
    echo "Waiting for pods to start..."
    sleep 10
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl get pods -n foyer-app
    
    echo ""
    echo "=== Services ==="
    kubectl get svc -n foyer-app
EOF

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Access your application at:"
echo "  http://$PUBLIC_IP:30083/tpFoyer17"
echo ""
echo "To check logs:"
echo "  ssh -i $PRIVATE_KEY ubuntu@$PUBLIC_IP"
echo "  kubectl logs -n foyer-app -l app=foyer-app -f"
