# Deployment Guide - Foyer Application

This guide covers all deployment methods for the Foyer application.

## 📋 Table of Contents

1. [Local Development](#local-development)
2. [Docker Deployment](#docker-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [AWS K3s Deployment](#aws-k3s-deployment)
5. [CI/CD with Jenkins](#cicd-with-jenkins)

---

## 🖥️ Local Development

### Prerequisites

- Java 17
- Maven 3.6+
- MySQL 8

### Steps

1. **Start MySQL**

   ```bash
   # Using Docker (recommended)
   docker run -d \
     --name mysql \
     -e MYSQL_ROOT_PASSWORD=root \
     -e MYSQL_DATABASE=tpFoyer17 \
     -p 3306:3306 \
     mysql:8
   ```

2. **Configure Application**

   Update `src/main/resources/application.properties`:

   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/tpFoyer17
   spring.datasource.username=root
   spring.datasource.password=root
   ```

3. **Build and Run**

   ```bash
   ./mvnw clean package
   ./mvnw spring-boot:run
   ```

4. **Access the Application**
   - API: http://localhost:8083/tpFoyer17
   - Swagger: http://localhost:8083/tpFoyer17/swagger-ui.html

---

## 🐳 Docker Deployment

### Quick Start (Recommended)

Use the provided development script:

```bash
# Interactive mode
./dev.sh

# Or command line mode
./dev.sh start    # Start application
./dev.sh logs     # View logs
./dev.sh stop     # Stop application
./dev.sh rebuild  # Rebuild and restart
```

### Manual Docker Compose

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove volumes
docker-compose down -v
```

### Building Docker Image Manually

```bash
# Build the image
docker build -t foyer-app:latest .

# Run the container
docker run -d \
  --name foyer-app \
  -p 8083:8083 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://mysqldb:3306/tpFoyer17 \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=root \
  foyer-app:latest
```

---

## ☸️ Kubernetes Deployment

### Prerequisites

- Kubernetes cluster (minikube, K3s, EKS, etc.)
- kubectl configured

### Deploy to Kubernetes

```bash
# Apply the deployment
kubectl apply -f k8s-deployment.yml

# Check deployment status
kubectl get all -n foyer-app

# View pods
kubectl get pods -n foyer-app

# View services
kubectl get svc -n foyer-app

# Check pod logs
kubectl logs -n foyer-app <pod-name>

# Access the application
kubectl get svc -n foyer-app foyer-app
# Note the NodePort (e.g., 30083)
# Access at: http://<node-ip>:30083/tpFoyer17
```

### Port Forwarding (for local testing)

```bash
kubectl port-forward -n foyer-app svc/foyer-app 8083:8083

# Access at: http://localhost:8083/tpFoyer17
```

### Scaling the Application

```bash
# Scale to 3 replicas
kubectl scale deployment foyer-app -n foyer-app --replicas=3

# Check status
kubectl get deployment -n foyer-app
```

### Cleanup

```bash
kubectl delete namespace foyer-app
```

---

## ☁️ AWS K3s Deployment

### Prerequisites

- AWS account with credentials configured
- Terraform >= 1.0
- EC2 key pair created in AWS
- AWS CLI configured

### Step-by-Step Deployment

#### 1. Configure Terraform

```bash
cd aws/terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region    = "us-east-1"
project_name  = "foyer-app"
key_pair_name = "your-key-pair-name"  # Must exist in AWS!
```

#### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
# Type 'yes' when prompted

# Note the outputs (especially the public IP)
```

#### 3. Access K3s Cluster

```bash
# Get the public IP
PUBLIC_IP=$(terraform output -raw k3s_master_public_ip)

# SSH to the instance
ssh -i ~/.ssh/your-key.pem ubuntu@$PUBLIC_IP

# View K3s status
sudo systemctl status k3s
kubectl get nodes
```

#### 4. Get Kubeconfig

```bash
# From your local machine
scp -i ~/.ssh/your-key.pem ubuntu@$PUBLIC_IP:~/.kube/config ~/.kube/foyer-k3s-config

# Set KUBECONFIG
export KUBECONFIG=~/.kube/foyer-k3s-config

# Test access
kubectl get nodes
```

#### 5. Deploy Application

```bash
# Copy deployment file to instance
scp -i ~/.ssh/your-key.pem k8s-deployment.yml ubuntu@$PUBLIC_IP:~/

# SSH and deploy
ssh -i ~/.ssh/your-key.pem ubuntu@$PUBLIC_IP
kubectl apply -f k8s-deployment.yml

# Check deployment
kubectl get all -n foyer-app

# Access the application
echo "http://$PUBLIC_IP:30083/tpFoyer17"
```

#### 6. Cleanup (When Done)

```bash
cd aws/terraform
terraform destroy
# Type 'yes' when prompted
```

**⚠️ Important**: Always destroy resources when done to avoid AWS charges!

---

## 🔄 CI/CD with Jenkins

### Prerequisites

- Jenkins server running
- Jenkins credentials configured:
  - `aws-credentials`: AWS credentials file
- Jenkins plugins:
  - Git
  - Pipeline
  - Terraform

### Pipeline Overview

The Jenkinsfile includes these stages:

1. **Checkout**: Clone the repository
2. **Validate Terraform**: Check syntax and formatting
3. **Terraform Init**: Initialize Terraform
4. **Terraform Plan**: Preview infrastructure changes
5. **Terraform Apply**: Deploy infrastructure
6. **Get Cluster Info**: Display cluster information

### Running the Pipeline

1. **Create Jenkins Pipeline Job**

   - New Item → Pipeline
   - Configure SCM: Git
   - Repository: https://github.com/Brahim-Gdoura/GL5-G2-Foyer.git
   - Branch: feature/universite
   - Script Path: Jenkinsfile

2. **Configure Credentials**

   - Add AWS credentials as file credential
   - ID: `aws-credentials`

3. **Run the Pipeline**
   - Click "Build Now"
   - Monitor console output

### Manual Trigger

```bash
# Trigger via Jenkins CLI (if configured)
java -jar jenkins-cli.jar -s http://jenkins-url/ build foyer-deployment
```

---

## 🔍 Verification & Testing

### Health Check Endpoints

```bash
# Health check
curl http://localhost:8083/tpFoyer17/actuator/health

# Application info
curl http://localhost:8083/tpFoyer17/actuator/info

# Metrics
curl http://localhost:8083/tpFoyer17/actuator/metrics
```

### API Testing

```bash
# Get all blocs
curl http://localhost:8083/tpFoyer17/bloc/retrieve-all-blocs

# Get all foyers
curl http://localhost:8083/tpFoyer17/foyer/retrieve-all-foyers

# Get all students
curl http://localhost:8083/tpFoyer17/etudiant/retrieve-all-etudiants
```

### Database Verification

```bash
# Connect to MySQL (Docker)
docker exec -it mysqldb mysql -uroot -proot tpFoyer17

# Show tables
SHOW TABLES;

# Check a table
SELECT * FROM bloc LIMIT 5;
```

---

## 🐛 Troubleshooting

### Application Won't Start

```bash
# Check logs
docker-compose logs spring_app

# Or in Kubernetes
kubectl logs -n foyer-app <pod-name>

# Common issues:
# - Database not ready: Wait 30-60 seconds
# - Port already in use: Stop conflicting service
# - Wrong database credentials: Check environment variables
```

### Database Connection Issues

```bash
# Test MySQL connection
docker exec -it mysqldb mysql -uroot -proot -e "SELECT 1"

# In Kubernetes
kubectl exec -it -n foyer-app <mysql-pod> -- mysql -uroot -proot -e "SELECT 1"
```

### Kubernetes Pod Not Starting

```bash
# Describe the pod
kubectl describe pod -n foyer-app <pod-name>

# Check events
kubectl get events -n foyer-app --sort-by='.lastTimestamp'

# Check if image exists
docker images | grep foyer-app
```

### Terraform Issues

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt

# Refresh state
terraform refresh

# Show current state
terraform show
```

---

## 📊 Monitoring

### Application Metrics

Access metrics at:

- http://localhost:8083/tpFoyer17/actuator/metrics
- http://localhost:8083/tpFoyer17/actuator/health

### Kubernetes Monitoring

```bash
# Watch pods
kubectl get pods -n foyer-app -w

# Resource usage
kubectl top pods -n foyer-app
kubectl top nodes

# View events
kubectl get events -n foyer-app --watch
```

### Docker Monitoring

```bash
# Container stats
docker stats

# Container logs
docker logs -f foyer-app

# Inspect container
docker inspect foyer-app
```

---

## 🔐 Security Considerations

### Production Checklist

- [ ] Change default database passwords
- [ ] Use secrets management (AWS Secrets Manager, Kubernetes Secrets)
- [ ] Restrict security group rules to specific IPs
- [ ] Enable HTTPS/TLS
- [ ] Implement authentication and authorization
- [ ] Regular security updates
- [ ] Enable audit logging
- [ ] Use non-root containers
- [ ] Scan images for vulnerabilities

### Securing Database Credentials

```bash
# In Kubernetes, use secrets
kubectl create secret generic db-credentials \
  --from-literal=username=root \
  --from-literal=password=your-secure-password \
  -n foyer-app
```

---

## 📝 Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [K3s Documentation](https://docs.k3s.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)

---

## 🆘 Getting Help

If you encounter issues:

1. Check the logs (application, containers, pods)
2. Verify configuration files
3. Check network connectivity
4. Review security group rules (AWS)
5. Consult the troubleshooting section
6. Check project README for updates

---

**Good luck with your deployment! 🚀**
