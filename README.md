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

## CI/CD Pipeline Stages

The automated CI/CD pipeline (GitHub Actions) executes the following stages in sequence:

1. **Test Stage**
   - Runs application tests
   - Validates code quality
   - **Duration:** ~2 minutes

2. **Build Stage**
   - Builds Docker image from Dockerfile
   - Pushes image to Docker Hub (`artie92/asset-manager:latest`)
   - **Duration:** ~5 minutes

3. **Terraform Stage**
   - Initializes Terraform
   - Plans infrastructure changes
   - Applies infrastructure (creates AWS resources)
   - Generates Ansible inventory file
   - **Duration:** ~5 minutes

4. **Ansible Stage**
   - Installs Docker and Kubernetes on all nodes
   - Initializes Kubernetes master
   - Joins worker nodes to cluster
   - Configures NFS server
   - **Duration:** ~15 minutes

5. **Helm Stage**
   - Configures kubectl
   - Deploys application using Helm chart
   - Waits for pods to be ready
   - Outputs ALB DNS name
   - **Duration:** ~3 minutes

**Total Pipeline Duration:** ~30 minutes

**Note:** If any stage fails, the pipeline stops and you must fix the issue before continuing.

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/ArtiomKrits92/Devops_Final_Project.git
cd Devops_Final_Project
```

## Prerequisites

### Required Tools (with specific versions)

Install the following tools before deployment:

- **AWS Academy Cloud Architecting [146272]** access (NOT Cloud Developing)
- **Terraform** >= 1.5.0
  ```bash
  # macOS
  brew install terraform
  
  # Or download from https://www.terraform.io/downloads
  ```
- **Ansible** 2.14.x (NOT 2.20+, incompatible with Amazon Linux 2)
  ```bash
  # macOS
  /usr/bin/python3 -m pip install --user 'ansible-core==2.14.17' 'ansible==8.7.0'
  export PATH="$HOME/Library/Python/3.9/bin:$PATH"
  
  # Verify installation
  ansible --version  # Should show ansible [core 2.14.17]
  ```
- **kubectl** >= 1.28
  ```bash
  # macOS
  brew install kubectl
  
  # Or download from https://kubernetes.io/docs/tasks/tools/
  ```
- **Helm** >= 3.12
  ```bash
  # macOS
  brew install helm
  
  # Or download from https://helm.sh/docs/intro/install/
  ```
- **AWS CLI** >= 2.x
  ```bash
  # macOS
  brew install awscli
  
  # Or download from https://aws.amazon.com/cli/
  ```
- **Docker** >= 24.x
  ```bash
  # macOS - Download Docker Desktop from https://www.docker.com/products/docker-desktop
  # Or
  brew install --cask docker
  ```

### Verify All Tools

```bash
terraform version
ansible --version
kubectl version --client
helm version
aws --version
docker --version
```

## AWS Academy Setup

1. Start AWS Academy Lab session
2. Get credentials from AWS Details:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_SESSION_TOKEN
   - AWS_REGION (usually us-east-1)
3. **AWS Academy Key Pair Note (IMPORTANT):**
   
   This project launches EC2 instances using an existing AWS key pair.
   
   In AWS Academy Learner Lab (region us-east-1), the default key pair is usually:
   - **`vockey`**
   
   Terraform defaults to `vockey`. If your lab uses a different key name, override it:
   
   **Manual usage:**
   ```bash
   terraform apply -auto-approve -var="key_name=<your-lab-keypair-name>"
   ```
   
   **CI/CD override (optional):**
   Add a GitHub secret `KEY_NAME` and it will be used automatically via `TF_VAR_key_name`.
4. Download the PEM file from AWS Academy:
   - Go to EC2 → Key Pairs
   - Find your key pair (usually `vockey`)
   - Download the `.pem` file
   - Save to `~/.ssh/cluster-key.pem` (or your preferred location)
   - Set permissions: `chmod 400 ~/.ssh/cluster-key.pem`

## GitHub Secrets (Required for CI/CD)

**The teacher/evaluator must add these 6 secrets to run the pipeline:**

### Quick Setup (5 minutes)

1. Go to: **Settings → Secrets and variables → Actions → New repository secret**

2. Add these 6 secrets:

| Secret Name | Value | Where to get it |
|-------------|-------|-----------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS Academy → AWS Details |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | AWS Academy → AWS Details |
| `AWS_SESSION_TOKEN` | Your AWS session token | AWS Academy → AWS Details |
| `DOCKER_USERNAME` | Docker Hub username | Your Docker Hub account |
| `DOCKER_PASSWORD` | Docker Hub access token | hub.docker.com/settings/security → New Access Token |
| `SSH_PRIVATE_KEY` | Contents of vockey.pem | AWS Academy → download the .pem file, copy entire contents |

### Getting the SSH Private Key

1. In AWS Academy, go to **EC2 → Key Pairs**
2. Find the key pair named `vockey` (default in AWS Academy)
3. Download the `.pem` file
4. Open it in a text editor
5. Copy **everything** (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
6. Paste as the value for `SSH_PRIVATE_KEY` secret

### Important Notes

- **Region:** Deploy only in `us-east-1` (AWS Academy default)
- **Session token expires** after 4 hours - update `AWS_SESSION_TOKEN` when it expires
- **Docker password** must be an Access Token (not your login password) - create at hub.docker.com/settings/security

## Deployment

### CI/CD Deployment (Recommended)

**Step 1: Configure GitHub Secrets** (see table above)

**Step 2: Trigger the Pipeline**

1. Go to: https://github.com/ArtiomKrits92/Devops_Final_Project/actions
2. Click **"Deploy to AWS"** workflow
3. Click **"Run workflow"** button (blue)
4. Select branch: `main`
5. Click **"Run workflow"** (green)

**Step 3: Wait for Completion (~30 minutes)**

The pipeline runs 5 stages automatically:
1. ✅ **Test** (~2 min) - Runs application tests
2. ✅ **Build** (~5 min) - Builds Docker image, pushes to Docker Hub
3. ✅ **Terraform** (~5 min) - Creates AWS infrastructure (VPC, EC2, ALB)
4. ✅ **Ansible** (~15 min) - Configures Kubernetes cluster
5. ✅ **Helm** (~3 min) - Deploys application

**Step 4: Get Application URL**

After all stages pass (green checkmarks):
1. Click on the **"Deploy Application"** job
2. Expand **"Get ALB DNS"** step
3. Copy the URL (e.g., `http://app-load-balancer-xxxxx.us-east-1.elb.amazonaws.com`)
4. Open in browser - wait 2-3 minutes for ALB health checks

**The application will show:**
- Dashboard with 6 users and 6 items
- Full IT Asset Management functionality

### Option 2: Manual Deployment

**Use this option if CI/CD is not available or for troubleshooting.**

**Step-by-Step Instructions:**

1. **Set AWS Credentials:**
   
   Get credentials from AWS Academy Lab session:
   - Go to AWS Academy → Lab → AWS Details
   - Copy the following values:
   
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key-id"
   export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
   export AWS_SESSION_TOKEN="your-session-token"
   export AWS_REGION="us-east-1"
   
   # Verify credentials
   aws sts get-caller-identity
   ```

2. **SSH Key Pair (AWS Academy):**
   
   **For AWS Academy Learner Lab:**
   - The default key pair is usually `vockey` (already exists in your lab)
   - Download the PEM file from EC2 → Key Pairs → `vockey`
   - Save to `~/.ssh/cluster-key.pem`
   - Set permissions: `chmod 400 ~/.ssh/cluster-key.pem`
   
   **If using a different key pair name:**
   ```bash
   # Override the default key name when running terraform apply
   terraform apply -auto-approve -var="key_name=<your-key-name>"
   ```

3. **Deploy Infrastructure with Terraform:**
   
   ```bash
   cd terraform
   
   # Initialize Terraform
   terraform init
   
   # Review what will be created
   terraform plan
   
   # Apply infrastructure (creates VPC, subnets, 3 EC2 instances, ALB, security groups)
   terraform apply
   
   # Type 'yes' when prompted
   ```
   
   **Expected Output:**
   - 3 EC2 instances (1 master, 2 workers)
   - 1 Application Load Balancer
   - VPC, subnets, security groups
   - Target groups and listeners
   
   **Time:** ~5 minutes

4. **Generate Ansible Inventory:**
   
   Terraform outputs the IP addresses. Create the inventory file:
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

5. **Run Ansible Playbooks:**
   
   Configure Kubernetes cluster and NFS server:
   
   ```bash
   cd ../ansible
   
   # Playbook 1: Install Docker and Kubernetes on all nodes
   ansible-playbook -i inventory.ini playbooks/01-common-setup.yml
   # Time: ~5 minutes
   
   # Playbook 2: Initialize Kubernetes master node
   ansible-playbook -i inventory.ini playbooks/02-master-setup.yml
   # Time: ~3 minutes
   
   # Wait for Kubernetes API server to be ready
   echo "Waiting 60 seconds for Kubernetes API server..."
   sleep 60
   
   # Playbook 3: Join worker nodes to cluster
   ansible-playbook -i inventory.ini playbooks/03-worker-setup.yml
   # Time: ~3 minutes
   
   # Playbook 4: Configure NFS server on master node
   ansible-playbook -i inventory.ini playbooks/04-nfs-setup.yml
   # Time: ~2 minutes
   ```
   
   **Total Time:** ~15 minutes
   
   **Verify Cluster:**
   ```bash
   # Get kubeconfig from master
   MASTER_IP=$(cd ../terraform && terraform output -raw master_public_ip)
   scp -i ~/.ssh/cluster-key.pem ec2-user@$MASTER_IP:~/.kube/config ~/.kube/config
   
   # Check nodes are ready
   kubectl get nodes
   # Expected: 3 nodes in "Ready" status
   ```

6. **Deploy Application with Helm:**
   
   ```bash
   # Navigate to Helm chart directory
   cd ../helm/asset-manager
   
   # Deploy application
   helm install asset-manager . \
     --set nfs.server=10.0.1.10 \
     --wait \
     --timeout=5m
   
   # Verify deployment
   kubectl get pods -l app.kubernetes.io/name=asset-manager
   # Expected: 1 pod in "Running" status
   
   kubectl get svc -l app.kubernetes.io/name=asset-manager
   # Expected: NodePort service on port 30080
   ```
   
   **Time:** ~3 minutes
   
   **Verify Application:**
   ```bash
   # Check pod logs
   kubectl logs -l app.kubernetes.io/name=asset-manager
   # Should see Gunicorn starting and dummy data loading
   ```

7. **Get Application URL:**
   
   ```bash
   cd ../../terraform
   terraform output load_balancer_dns
   ```
   
   Copy the DNS name and open in browser: `http://<ALB_DNS>`

## Accessing the Application

### Finding the Load Balancer Address

**Option 1: Using Terraform output**
```bash
cd terraform
terraform output load_balancer_dns
```

**Option 2: Using AWS CLI**
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `app-load-balancer`)].DNSName' --output text
```

**Option 3: From AWS Console**
1. Go to EC2 → Load Balancers
2. Find load balancer named `app-load-balancer-*`
3. Copy the DNS name

### Accessing the Application

1. Open browser: `http://<ALB_DNS>`
2. Application should show dummy data immediately:
   - 6 users (Brandon Guidelines, Carnegie Mondover, John Doe, etc.)
   - 6 items (Laptops, PCs, Accessories, Licenses)
   - Dashboard with totals and statistics

### Application User Guide

For detailed instructions on using the application features, see [USER_GUIDE.md](USER_GUIDE.md)

## Testing

### Health Check Procedures

1. **Verify ALB is accessible:**
   ```bash
   curl -I http://<ALB_DNS>/
   ```
   Expected: `HTTP/1.1 200 OK`

2. **Verify application homepage:**
   ```bash
   curl http://<ALB_DNS>/
   ```
   Expected: HTML page with "IT Asset Management" title and dashboard showing dummy data

3. **Test endpoints:**
   - Homepage: `http://<ALB_DNS>/`
   - Show Users: `http://<ALB_DNS>/show_users`
   - Show Items: `http://<ALB_DNS>/show_stock_items`
   - Add User form: `http://<ALB_DNS>/add_user`
   - Add Item form: `http://<ALB_DNS>/add_item`

### Kubernetes Cluster Verification

```bash
# Check all nodes are ready
kubectl get nodes
# Expected: 3 nodes in "Ready" status

# Check pods are running
kubectl get pods -l app.kubernetes.io/name=asset-manager
# Expected: 1 pod in "Running" status

# Check service is exposed
kubectl get svc -l app.kubernetes.io/name=asset-manager
# Expected: NodePort service on port 30080

# Check persistent volumes
kubectl get pv
kubectl get pvc
# Expected: PV and PVC in "Bound" status
```

### Application Functionality Tests

1. **Verify dummy data is visible:**
   - Open `http://<ALB_DNS>/` in browser
   - Should see 6 users and 6 items immediately
   - Dashboard should show totals

2. **Test POST operations:**
   - Create a new user via `/add_user` form
   - Create a new item via `/add_item` form
   - Both should complete without 504 errors

3. **View logs:**
   ```bash
   kubectl logs -l app.kubernetes.io/name=asset-manager --tail=50
   ```
   Expected: Gunicorn access logs showing GET and POST requests

## Troubleshooting

### Common Issues and Solutions

#### 1. ALB Returns 504 Gateway Timeout

**Symptoms:** ALB health checks fail or POST requests timeout

**Diagnosis:**
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check pods are running
kubectl get pods -l app.kubernetes.io/name=asset-manager

# Check service endpoints
kubectl get endpoints -l app.kubernetes.io/name=asset-manager
```

**Solutions:**
- Verify pods are in "Running" state: `kubectl get pods`
- Check NodePort service is correct (port 30080)
- Verify security groups allow traffic on port 30080
- Check if master node is incorrectly registered in target group (remove it)
- Verify ALB idle timeout is set to 120 seconds

#### 2. ALB Returns 502 Bad Gateway

**Symptoms:** ALB can't connect to backend

**Solutions:**
- Check if pods crashed: `kubectl get pods` and `kubectl describe pod <pod-name>`
- Check pod logs: `kubectl logs <pod-name>`
- Verify NFS mount is working: `kubectl exec <pod-name> -- ls -la /data`
- Restart deployment: `kubectl rollout restart deployment asset-manager`

#### 3. Nodes Not Ready

**Symptoms:** `kubectl get nodes` shows "NotReady" status

**Diagnosis:**
```bash
# Check kubelet status on nodes
ssh ec2-user@<node-ip> 'sudo systemctl status kubelet'

# Check Calico pods
kubectl get pods -n kube-system | grep calico
```

**Solutions:**
- Restart kubelet: `sudo systemctl restart kubelet`
- Check Calico pods are running: `kubectl get pods -n kube-system`
- Verify network connectivity between nodes

#### 4. NFS Mount Issues

**Symptoms:** Pods can't write to `/data`, data not persisting

**Diagnosis:**
```bash
# Check NFS server is running
ssh ec2-user@<master-ip> 'sudo systemctl status nfs-server'

# Check NFS exports
ssh ec2-user@<master-ip> 'sudo exportfs -v'

# Test mount in pod
kubectl exec <pod-name> -- mount | grep nfs
kubectl exec <pod-name> -- ls -la /data
```

**Solutions:**
- Verify NFS server is running on master node
- Check security groups allow port 2049 (NFS) and 111 (RPC)
- Verify NFS server IP in Helm values: `--set nfs.server=10.0.1.10`
- Check PV/PVC are bound: `kubectl get pv,pvc`

#### 5. POST Requests Timeout (504)

**Symptoms:** GET requests work, but POST requests (create user/item) timeout

**Solutions:**
- Verify only 1 replica is running (to avoid NFS write conflicts)
- Check Gunicorn is using 1 worker: `kubectl logs <pod-name> | grep gunicorn`
- Verify file locking is working (check logs for file write errors)
- Check ALB idle timeout is 120 seconds

#### 6. AWS Session Expired

**Symptoms:** Terraform/Ansible commands fail with authentication errors

**Solutions:**
- Get new credentials from AWS Academy Lab session
- Update GitHub Secrets if using CI/CD
- Export new credentials: `export AWS_SESSION_TOKEN="..."`

#### 7. Ansible Compatibility Issues

**Symptoms:** `Module result deserialization failed: No start of json char found`

**Solutions:**
- Use Ansible 2.14.x (not 2.20+)
- Install: `pip3 install 'ansible-core==2.14.17' 'ansible==8.7.0'`
- See "Known Issues" section below

#### 8. Docker Image Not Pulling

**Symptoms:** Pods use old image despite new build

**Solutions:**
- Force image pull: `kubectl set image deployment/asset-manager asset-manager=artie92/asset-manager:latest`
- Restart deployment: `kubectl rollout restart deployment asset-manager`
- Delete pods to force fresh pull: `kubectl delete pods -l app.kubernetes.io/name=asset-manager`

### Log File Locations

**Application logs:**
```bash
kubectl logs -l app.kubernetes.io/name=asset-manager
```

**Kubernetes cluster logs:**
```bash
# Master node
ssh ec2-user@<master-ip> 'sudo journalctl -u kubelet -n 100'

# Worker nodes
ssh ec2-user@<worker-ip> 'sudo journalctl -u kubelet -n 100'
```

**NFS server logs:**
```bash
ssh ec2-user@<master-ip> 'sudo journalctl -u nfs-server -n 100'
```

**Terraform logs:**
- Check `terraform/terraform.tfstate` for resource status
- Run `terraform show` to see current state

**Ansible logs:**
- Ansible output shows in terminal during playbook execution
- Check for errors in playbook output

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

### Ansible Version Compatibility

**Issue:** Ansible 2.20+ has compatibility issues with Amazon Linux 2 (Python 3.7)

**Error:** `Module result deserialization failed: No start of json char found`

**Solution:** Use Ansible 2.14.x:

```bash
brew uninstall ansible
/usr/bin/python3 -m pip install --user 'ansible-core==2.14.17'
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
```

### AWS Academy Course Selection

**Critical:** This project requires **AWS Academy Cloud Architecting [146272]**

**DO NOT use Cloud Developing [134969]** - it has restricted IAM permissions that block EC2 instance creation.

### Other Issues

- AWS Academy session expires after 4 hours
- NFS requires ports 2049, 111 open in security groups
- Use t3.medium instances (t2.micro too small for K8s)

## License

MIT
