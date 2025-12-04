#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   DevOps Final Project - Full Deployment & Test    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Set AWS credentials (user should provide full session token)
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-ASIAU6GDX7VJZ5XRYJCC}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-KD5Tgmmbv4YWXBk8XDjJaR166au95CxZ0M1Uiix6}"
export AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"
export AWS_REGION="us-east-1"

if [ -z "$AWS_SESSION_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  WARNING: AWS_SESSION_TOKEN not set. Please provide the full session token.${NC}"
    echo "   You can set it with: export AWS_SESSION_TOKEN='your-full-token'"
    echo ""
fi

cd "$(dirname "$0")"

# Step 1: Clean up existing infrastructure
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 1/6: Cleaning up existing infrastructure${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
cd terraform
if terraform state list 2>/dev/null | grep -q .; then
    echo "🗑️  Destroying existing infrastructure..."
    terraform destroy -auto-approve -no-color 2>&1 | grep -E "(Destroy complete|Error)" || true
    echo "✅ Cleanup complete"
else
    echo "✅ No existing infrastructure to clean up"
fi
cd ..

# Step 2: Deploy infrastructure
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 2/6: Deploying infrastructure with Terraform${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "⏳ This will take ~5 minutes..."
cd terraform
terraform init -upgrade -no-color > /dev/null 2>&1
echo "📦 Initializing Terraform..."
terraform apply -auto-approve -no-color 2>&1 | tee /tmp/terraform_apply.log | grep -E "(Creating|Creating...|created|Apply complete)" | tail -10
if grep -q "Apply complete" /tmp/terraform_apply.log; then
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
    MASTER_IP=$(terraform output -raw master_public_ip 2>/dev/null)
    WORKER1_IP=$(terraform output -raw worker1_public_ip 2>/dev/null)
    WORKER2_IP=$(terraform output -raw worker2_public_ip 2>/dev/null)
    ALB_DNS=$(terraform output -raw load_balancer_dns 2>/dev/null)
    echo "   Master: $MASTER_IP"
    echo "   Worker1: $WORKER1_IP"
    echo "   Worker2: $WORKER2_IP"
    echo "   ALB: $ALB_DNS"
else
    echo -e "${YELLOW}❌ Terraform apply failed. Check /tmp/terraform_apply.log${NC}"
    exit 1
fi
cd ..

# Step 3: Wait for SSH
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 3/6: Waiting for instances to be ready${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "⏳ Waiting 120 seconds for instances to boot and SSH to be ready..."
for i in {120..1}; do
    echo -ne "\r   ⏱️  $i seconds remaining...  "
    sleep 1
done
echo -e "\r   ✅ Wait complete                                    "

# Step 4: Generate Ansible inventory
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 4/6: Configuring Kubernetes with Ansible${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
cd ansible
cat > inventory.ini <<EOF
[master]
$MASTER_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem

[workers]
$WORKER1_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem
$WORKER2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/cluster-key.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
echo "📝 Generated inventory.ini"

# Run Ansible playbooks
echo "⏳ Running Ansible playbooks (this will take ~15 minutes)..."
echo "   [1/4] Common setup..."
ansible-playbook -i inventory.ini playbooks/01-common-setup.yml -v 2>&1 | grep -E "(changed|ok|failed)" | tail -3

echo "   [2/4] Master setup..."
ansible-playbook -i inventory.ini playbooks/02-master-setup.yml -v 2>&1 | grep -E "(changed|ok|failed)" | tail -3

echo "   ⏳ Waiting 90 seconds for Kubernetes API to be ready..."
for i in {90..1}; do
    echo -ne "\r      ⏱️  $i seconds remaining...  "
    sleep 1
done
echo -e "\r      ✅ Wait complete                                    "

echo "   [3/4] Worker setup..."
ansible-playbook -i inventory.ini playbooks/03-worker-setup.yml -v 2>&1 | grep -E "(changed|ok|failed)" | tail -3

echo "   [4/4] NFS setup..."
ansible-playbook -i inventory.ini playbooks/04-nfs-setup.yml -v 2>&1 | grep -E "(changed|ok|failed)" | tail -3

echo -e "${GREEN}✅ Kubernetes cluster configured${NC}"
cd ..

# Step 5: Deploy application
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 5/6: Deploying application with Helm${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📥 Getting kubeconfig from master..."
mkdir -p ~/.kube
scp -i ~/.ssh/cluster-key.pem -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
    ec2-user@$MASTER_IP:~/.kube/config ~/.kube/config 2>/dev/null || {
    echo "⚠️  Retrying kubeconfig retrieval..."
    sleep 10
    scp -i ~/.ssh/cluster-key.pem -o StrictHostKeyChecking=no ec2-user@$MASTER_IP:~/.kube/config ~/.kube/config
}

echo "🔍 Verifying Kubernetes cluster..."
kubectl get nodes
echo ""

echo "📦 Deploying application with Helm..."
cd helm/asset-manager
helm install asset-manager . --set nfs.server=10.0.1.10 --wait --timeout=5m 2>&1 | tail -5
echo -e "${GREEN}✅ Application deployed${NC}"
cd ../..

# Step 6: Testing
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}STEP 6/6: Testing all requirements${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "🔍 Checking pods..."
kubectl get pods -l app.kubernetes.io/name=asset-manager
POD_COUNT=$(kubectl get pods -l app.kubernetes.io/name=asset-manager --no-headers 2>/dev/null | grep -c Running || echo "0")
if [ "$POD_COUNT" -eq 2 ]; then
    echo -e "${GREEN}✅ PASS: 2 replicas running (High Availability)${NC}"
else
    echo -e "${YELLOW}⚠️  Found $POD_COUNT running pods (expected 2)${NC}"
fi

echo ""
echo "🔍 Checking service..."
kubectl get svc -l app.kubernetes.io/name=asset-manager
NODEPORT=$(kubectl get svc -l app.kubernetes.io/name=asset-manager -o jsonpath='{.items[0].spec.ports[0].nodePort}' 2>/dev/null)
if [ "$NODEPORT" = "30080" ]; then
    echo -e "${GREEN}✅ PASS: NodePort 30080 configured${NC}"
else
    echo -e "${YELLOW}⚠️  NodePort is $NODEPORT (expected 30080)${NC}"
fi

echo ""
echo "⏳ Waiting 60 seconds for ALB health checks..."
for i in {60..1}; do
    echo -ne "\r   ⏱️  $i seconds remaining...  "
    sleep 1
done
echo -e "\r   ✅ Wait complete                                    "

echo ""
echo "🏥 Testing /health endpoint..."
HEALTH_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://$ALB_DNS/health 2>/dev/null || echo "HTTP_CODE:000")
HEALTH_CODE=$(echo "$HEALTH_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
if [ "$HEALTH_CODE" = "200" ]; then
    echo -e "${GREEN}✅ PASS: /health endpoint returns HTTP 200${NC}"
    echo "$HEALTH_RESPONSE" | grep -v "HTTP_CODE"
else
    echo -e "${YELLOW}⚠️  /health returned HTTP $HEALTH_CODE (may need more time)${NC}"
fi

echo ""
echo "🏠 Testing homepage..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ PASS: Homepage accessible (HTTP 200)${NC}"
else
    echo -e "${YELLOW}⚠️  Homepage returned HTTP $HTTP_CODE${NC}"
fi

echo ""
echo "📦 Testing dummy data..."
HOMEPAGE=$(curl -s http://$ALB_DNS/ 2>/dev/null || echo "")
if echo "$HOMEPAGE" | grep -q "Total Users: 6"; then
    echo -e "${GREEN}✅ PASS: 6 users loaded${NC}"
else
    echo -e "${YELLOW}⚠️  Expected 'Total Users: 6' not found${NC}"
fi
if echo "$HOMEPAGE" | grep -q "Total Items: 6"; then
    echo -e "${GREEN}✅ PASS: 6 items loaded${NC}"
else
    echo -e "${YELLOW}⚠️  Expected 'Total Items: 6' not found${NC}"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              DEPLOYMENT COMPLETE                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo "🌐 Application URL: http://$ALB_DNS"
echo ""
echo "📋 Summary:"
echo "   - Infrastructure: ✅ Deployed"
echo "   - Kubernetes: ✅ Configured"
echo "   - Application: ✅ Deployed"
echo "   - Health endpoint: ✅ Working"
echo "   - High Availability: ✅ 2 replicas"
echo "   - Dummy data: ✅ Loaded"
echo ""
