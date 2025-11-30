# IT Asset Management - DevOps Final Project

## Student Information

- **Name**: Artiom Krits
- **ID**: 320763105
- **GitHub**: https://github.com/ArtiomKrits92/Devops_Final_Project

## Project Overview

This project deploys a Flask IT Asset Management application to AWS using:
- **Terraform** for Infrastructure as Code
- **Ansible** for Configuration Management
- **Kubernetes** for container orchestration
- **Helm** for application deployment
- **GitHub Actions** for CI/CD automation

## Prerequisites

- Terraform >= 1.5.0
- Ansible >= 2.14
- kubectl >= 1.28
- Helm >= 3.12
- AWS CLI >= 2.x
- Docker >= 24.x

## AWS Academy Setup

1. Start AWS Academy Lab session
2. Get credentials from AWS Details:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_SESSION_TOKEN
   - AWS_REGION (usually us-east-1)
3. Create SSH key pair named `cluster-key` in EC2
4. Download key file to `~/.ssh/cluster-key.pem`
5. Set permissions: `chmod 400 ~/.ssh/cluster-key.pem`

## GitHub Secrets

For CI/CD, add these secrets in GitHub Settings → Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `SSH_PRIVATE_KEY` (contents of cluster-key.pem)

**Note:** AWS Academy session tokens expire after 4 hours. Update `AWS_SESSION_TOKEN` when it expires.

## Deployment

### Option 1: Automated (CI/CD)

1. Push to main branch - pipeline runs automatically
2. Wait 15-20 minutes for deployment
3. Get ALB DNS: `cd terraform && terraform output load_balancer_dns`

### Option 2: Manual

1. **Set AWS credentials:**
   ```bash
   export AWS_ACCESS_KEY_ID="your-key"
   export AWS_SECRET_ACCESS_KEY="your-secret"
   export AWS_SESSION_TOKEN="your-token"
   export AWS_REGION="us-east-1"
   ```

2. **Deploy infrastructure:**
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

3. **Generate Ansible inventory:**
   ```bash
   MASTER_IP=$(terraform output -raw master_public_ip)
   WORKER1_IP=$(terraform output -raw worker1_public_ip)
   WORKER2_IP=$(terraform output -raw worker2_public_ip)
   
   cat > ../ansible/inventory.ini <<EOF
   [master]
   $MASTER_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem
   
   [workers]
   $WORKER1_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem
   $WORKER2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem
   
   [all:vars]
   ansible_python_interpreter=/usr/bin/python3
   EOF
   ```

4. **Run Ansible playbooks:**
   ```bash
   cd ../ansible
   ansible-playbook -i inventory.ini playbooks/01-common-setup.yml
   ansible-playbook -i inventory.ini playbooks/02-master-setup.yml
   sleep 60
   ansible-playbook -i inventory.ini playbooks/03-worker-setup.yml
   ansible-playbook -i inventory.ini playbooks/04-nfs-setup.yml
   ```

5. **Deploy with Helm:**
   ```bash
   # Get kubeconfig from master
   scp -i ~/.ssh/cluster-key.pem ec2-user@$MASTER_IP:~/.kube/config ~/.kube/config
   
   # Deploy application
   cd ../helm/asset-manager
   helm install asset-manager . --set nfs.server=10.0.1.10
   ```

## Accessing the Application

1. Get ALB DNS: `cd terraform && terraform output load_balancer_dns`
2. Open browser: `http://<ALB_DNS>`
3. Application should show dummy data immediately

## Testing

- Health check: `curl http://<ALB_DNS>/`
- Check pods: `kubectl get pods`
- Check services: `kubectl get svc`
- View logs: `kubectl logs <pod-name>`

## Troubleshooting

- **ALB unhealthy:** Check pods are running and NodePort service is correct
- **Nodes not ready:** Check kubelet status and Calico pods
- **NFS issues:** Verify NFS server running and security groups allow port 2049
- **Session expired:** Get new credentials from AWS Academy

## Cleanup

```bash
helm uninstall asset-manager
cd terraform
terraform destroy
```

## Project Structure

```
Devops_Final_Project/
├── .github/workflows/deploy.yml    # CI/CD pipeline
├── ansible/                        # Ansible playbooks
├── helm/asset-manager/              # Helm chart
├── terraform/                      # Terraform configuration
├── website/                        # Flask application
├── Dockerfile                      # Docker image
└── README.md                       # This file
```

## Known Issues

- AWS Academy session expires after 4 hours
- NFS requires ports 2049, 111 open in security groups
- Use t3.medium instances (t2.micro too small for K8s)

## License

MIT
