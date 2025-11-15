# Terraform Infrastructure - K3s on AWS

This directory contains Terraform configuration to deploy a K3s cluster on AWS EC2.

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- An existing EC2 key pair in AWS
- Basic knowledge of AWS and Kubernetes

## 🗂️ Files

- `main.tf` - Main infrastructure configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `terraform.tfvars.example` - Example variable values

## 🚀 Quick Start

### 1. Configure Variables

Copy the example file and edit with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Update the following:

- `aws_region` - Your preferred AWS region
- `key_pair_name` - Your EC2 key pair name (must exist)
- `project_name` - Custom project name (optional)

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview Changes

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 5. Access Your Cluster

After deployment completes, you'll see outputs with:

- K3s master public IP
- SSH connection command
- Application access URL

To get the kubeconfig:

```bash
# SSH to the instance
ssh -i your-key.pem ubuntu@<PUBLIC_IP>

# View the kubeconfig
cat ~/.kube/config

# Copy it to your local machine
scp -i your-key.pem ubuntu@<PUBLIC_IP>:~/.kube/config ~/.kube/k3s-config

# Set KUBECONFIG environment variable
export KUBECONFIG=~/.kube/k3s-config
```

## 📦 Deploying the Application

Once you have access to the cluster, deploy the Foyer application:

```bash
# Copy the deployment file to the instance
scp -i your-key.pem k8s-deployment.yml ubuntu@<PUBLIC_IP>:~/

# SSH to the instance
ssh -i your-key.pem ubuntu@<PUBLIC_IP>

# Apply the deployment
kubectl apply -f k8s-deployment.yml

# Check deployment status
kubectl get pods -n foyer-app
kubectl get svc -n foyer-app

# Access the application
# The app will be available at: http://<PUBLIC_IP>:30083/tpFoyer17
```

## 🔧 Infrastructure Details

### Resources Created

- **VPC**: Custom VPC with DNS support
- **Internet Gateway**: For public internet access
- **Subnet**: Public subnet with auto-assign public IP
- **Route Table**: Routes to internet gateway
- **Security Group**: Allows SSH, K3s API, HTTP/HTTPS, NodePorts
- **EC2 Instance**: Ubuntu 22.04 with K3s installed

### Security Group Rules

| Port Range  | Protocol | Purpose                      |
| ----------- | -------- | ---------------------------- |
| 22          | TCP      | SSH access                   |
| 6443        | TCP      | K3s API server               |
| 80          | TCP      | HTTP                         |
| 443         | TCP      | HTTPS                        |
| 30000-32767 | TCP      | Kubernetes NodePort services |

### Instance Specifications

- **Type**: t2.medium (2 vCPU, 4 GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 20 GB gp3
- **K3s Version**: Latest stable

## 🔍 Useful Commands

### View Outputs

```bash
terraform output
```

### View Specific Output

```bash
terraform output k3s_master_public_ip
```

### SSH to Instance

```bash
terraform output -raw ssh_connection | sh
```

### Destroy Infrastructure

```bash
terraform destroy
```

## 🐛 Troubleshooting

### K3s Not Starting

SSH to the instance and check:

```bash
sudo systemctl status k3s
sudo journalctl -u k3s -f
```

### Can't Access Application

Check pods are running:

```bash
kubectl get pods -n foyer-app
kubectl logs -n foyer-app <pod-name>
```

Check services:

```bash
kubectl get svc -n foyer-app
```

### Terraform State Issues

If state gets corrupted:

```bash
terraform refresh
terraform state list
```

## 📊 Costs

Estimated monthly cost (us-east-1):

- t2.medium EC2: ~$35/month
- EBS gp3 20GB: ~$2/month
- Data transfer: Variable

**Total**: ~$37-50/month

💡 **Tip**: Don't forget to destroy resources when done to avoid charges!

## 🔐 Security Notes

⚠️ **Important Security Considerations**:

1. The security group allows SSH from `0.0.0.0/0` - restrict this to your IP
2. K3s API is exposed - consider using a bastion host for production
3. Store `terraform.tfvars` securely - it may contain sensitive data
4. Use AWS Secrets Manager for sensitive configuration in production

## 📝 Variables Reference

| Variable           | Description              | Default       |
| ------------------ | ------------------------ | ------------- |
| aws_region         | AWS region               | us-east-1     |
| project_name       | Project name for tagging | k3s-foyer-app |
| instance_type      | EC2 instance type        | t2.medium     |
| vpc_cidr           | VPC CIDR block           | 10.0.0.0/16   |
| public_subnet_cidr | Public subnet CIDR       | 10.0.1.0/24   |
| key_pair_name      | EC2 key pair name        | my-key-pair   |

## 📤 Outputs Reference

| Output                | Description                    |
| --------------------- | ------------------------------ |
| k3s_master_public_ip  | Public IP of master node       |
| k3s_master_private_ip | Private IP of master node      |
| ssh_connection        | SSH command to connect         |
| k3s_access_url        | K3s API URL                    |
| application_url       | Application access URL         |
| kubeconfig_command    | Command to retrieve kubeconfig |

## 🔄 CI/CD Integration

This infrastructure is integrated with Jenkins. See the main `Jenkinsfile` for the automated deployment pipeline.

## 📚 Additional Resources

- [K3s Documentation](https://docs.k3s.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
