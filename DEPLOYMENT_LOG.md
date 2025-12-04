# Deployment Test Log - December 1, 2025

## Infrastructure Details

- **AWS Account:** 058264329146
- **AWS Course:** Cloud Architecting [146272]
- **Master Node:** 13.222.97.239 (Private: 10.0.1.10)
- **Worker Node 1:** 3.234.206.237 (Private: 10.0.1.11)
- **Worker Node 2:** 44.197.190.255 (Private: 10.0.1.12)
- **Load Balancer:** app-load-balancer-1503794428.us-east-1.elb.amazonaws.com

## Deployment Timeline

### 1. Terraform Infrastructure ✅ (5 minutes)

- VPC, subnets (us-east-1a, us-east-1b)
- 3 EC2 instances (t3.medium)
- Application Load Balancer
- Security groups

**Resources created:** 18

### 2. SSH Key Issue ✅ (Resolved)

**Problem:** AWS had existing "cluster-key" with mismatched public key.

**Solution:**
```bash
aws ec2 delete-key-pair --key-name cluster-key
aws ec2 import-key-pair --key-name cluster-key --public-key-material fileb:///tmp/cluster-key.pub
terraform destroy -auto-approve
terraform apply -auto-approve
```

### 3. Ansible Compatibility Issue ✅ (Resolved)

**Problem:** Ansible 2.20.0 incompatible with Python 3.7 on Amazon Linux 2.

**Error:** "Module result deserialization failed: No start of json char found"

**Solution:**
```bash
brew uninstall ansible
/usr/bin/python3 -m pip install --user 'ansible-core==2.14.17'
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
```

**Verification:**
```bash
~/Library/Python/3.9/bin/ansible --version
# ansible [core 2.14.17]
```

### 4. Ansible Configuration ✅ (~15 minutes)

**4.1 Common Setup (01-common-setup.yml):**
- Docker installed from Amazon Linux 2 default repos
- Kubernetes tools (kubeadm, kubelet, kubectl) installed
- Kernel parameters configured (net.bridge.bridge-nf-call-iptables, net.ipv4.ip_forward)
- Swap disabled
- br_netfilter module loaded

**4.2 Master Setup (02-master-setup.yml):**
- Kubernetes cluster initialized with kubeadm
- Calico CNI network plugin deployed
- Join command generated and saved

**4.3 Worker Setup (03-worker-setup.yml):**
- Both worker nodes successfully joined the cluster
- Nodes registered and ready

**4.4 NFS Setup (04-nfs-setup.yml):**
- NFS server installed and configured on master
- NFS share created at `/data/nfs-share`
- NFS clients installed on workers
- NFS mounted on workers

### 5. Kubernetes Cluster Status ✅

```
NAME                        STATUS   ROLES           AGE     VERSION
ip-10-0-1-10.ec2.internal   Ready    control-plane   8m13s   v1.28.15
ip-10-0-1-11.ec2.internal   Ready    <none>          7m22s   v1.28.15
ip-10-0-1-12.ec2.internal   Ready    <none>          7m22s   v1.28.15
```

All 3 nodes in "Ready" status.

### 6. Helm Deployment ✅ (~3 minutes)

**Chart deployed:** asset-manager

**Status:**
- Deployment created: 2 replicas (High Availability)
- Service: NodePort 30080
- PersistentVolume: Bound (NFS)
- PersistentVolumeClaim: Bound
- Health checks configured to use `/health` endpoint

**Improvements:**
- Multi-platform Docker image built (amd64 + arm64)
- Health endpoint added at `/health` for Kubernetes probes
- Replicas set to 2 for high availability
- Data reload on homepage for consistency

### 7. Application Testing ✅

**URL:** http://app-load-balancer-1323528933.us-east-1.elb.amazonaws.com

**Health Endpoint:** http://app-load-balancer-1323528933.us-east-1.elb.amazonaws.com/health

**Status:** Application deployed with all improvements

**Features:**
- ✅ Health endpoint returns HTTP 200
- ✅ Homepage accessible
- ✅ Dummy data loads on first access (6 users, 6 items)
- ✅ POST requests working (no 504 timeouts)
- ✅ High availability (2 replicas)
- ✅ NFS persistence working

## Key Lessons Learned

1. **AWS Academy Course Matters:** Cloud Architecting [146272] required (Cloud Developing blocks EC2)
2. **SSH Key Management:** Verify fingerprints match between local and AWS before deployment
3. **Ansible Version:** Use 2.14.x for Amazon Linux 2 (Python 3.7), not 2.20+
4. **Timing:** EC2 instances need 2-3 minutes for SSH readiness
5. **Subnet AZs:** Explicitly set different availability zones for ALB
6. **Docker Repository:** Amazon Linux 2 has Docker in default repos - no need for external repo
7. **Platform Compatibility:** Docker images must support ARM64 for EC2 instances

## Total Deployment Time

- Terraform: ~5 minutes
- Ansible: ~15 minutes
- Helm: ~3 minutes
- **Total: ~25 minutes** (excluding image build/push)

## Cleanup Commands

```bash
# On master node
helm uninstall asset-manager

# From local machine
cd terraform
terraform destroy -auto-approve
```
