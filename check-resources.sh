#!/bin/bash

echo "================================================"
echo "🔍 SteadyStackAI Resource Check"
echo "================================================"
echo "Time: $(date)"
echo ""

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TOTAL_COST=0
WARNINGS=0

# =====================
# CHECK EKS CLUSTER
# =====================
echo "📦 EKS Clusters:"
EKS_CLUSTERS=$(aws eks list-clusters \
  --region eu-west-1 \
  --query 'clusters' \
  --output text)

if [ -z "$EKS_CLUSTERS" ]; then
  echo -e "   ${GREEN}✅ No EKS clusters running${NC}"
else
  for cluster in $EKS_CLUSTERS; do
    echo -e "   ${RED}⚠️  Running: $cluster${NC}"
    echo "   💰 Cost: ~\$0.10/hour = \$2.40/day"
    TOTAL_COST=$(echo "$TOTAL_COST + 0.10" | bc)
    WARNINGS=$((WARNINGS + 1))
  done
fi

echo ""

# =====================
# CHECK EC2 INSTANCES
# =====================
echo "💻 EC2 Instances:"
EC2_INSTANCES=$(aws ec2 describe-instances \
  --region eu-west-1 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags[?Key==`Name`].Value]' \
  --output text)

if [ -z "$EC2_INSTANCES" ]; then
  echo -e "   ${GREEN}✅ No EC2 instances running${NC}"
else
  echo -e "   ${RED}⚠️  Running instances:${NC}"
  echo "$EC2_INSTANCES" | while read line; do
    echo "   → $line"
  done
  EC2_COUNT=$(aws ec2 describe-instances \
    --region eu-west-1 \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text | wc -w)
  echo "   💰 Cost: ~\$0.047/hour each"
  TOTAL_COST=$(echo "$TOTAL_COST + (0.047 * $EC2_COUNT)" | bc)
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# =====================
# CHECK NAT GATEWAYS
# =====================
echo "🌐 NAT Gateways:"
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways \
  --region eu-west-1 \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,State]' \
  --output text)

if [ -z "$NAT_GATEWAYS" ]; then
  echo -e "   ${GREEN}✅ No NAT Gateways running${NC}"
else
  echo -e "   ${RED}⚠️  Running:${NC}"
  echo "$NAT_GATEWAYS" | while read line; do
    echo "   → $line"
  done
  echo "   💰 Cost: ~\$0.045/hour = \$1.08/day"
  TOTAL_COST=$(echo "$TOTAL_COST + 0.045" | bc)
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# =====================
# CHECK LOAD BALANCERS
# =====================
echo "⚖️  Load Balancers:"
CLASSIC_LBS=$(aws elb describe-load-balancers \
  --region eu-west-1 \
  --query 'LoadBalancerDescriptions[*].LoadBalancerName' \
  --output text)

ALB_LBS=$(aws elbv2 describe-load-balancers \
  --region eu-west-1 \
  --query 'LoadBalancers[*].LoadBalancerName' \
  --output text)

if [ -z "$CLASSIC_LBS" ] && [ -z "$ALB_LBS" ]; then
  echo -e "   ${GREEN}✅ No Load Balancers running${NC}"
else
  if [ ! -z "$CLASSIC_LBS" ]; then
    echo -e "   ${YELLOW}⚠️  Classic LBs:${NC}"
    for lb in $CLASSIC_LBS; do
      echo "   → $lb"
      TOTAL_COST=$(echo "$TOTAL_COST + 0.025" | bc)
    done
  fi
  if [ ! -z "$ALB_LBS" ]; then
    echo -e "   ${YELLOW}⚠️  ALBs:${NC}"
    for lb in $ALB_LBS; do
      echo "   → $lb"
      TOTAL_COST=$(echo "$TOTAL_COST + 0.025" | bc)
    done
  fi
  echo "   💰 Cost: ~\$0.025/hour each"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

# =====================
# CHECK VPCs
# =====================
echo "🔒 VPCs (non-default):"
VPCS=$(aws ec2 describe-vpcs \
  --region eu-west-1 \
  --filters "Name=isDefault,Values=false" \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value]' \
  --output text)

if [ -z "$VPCS" ]; then
  echo -e "   ${GREEN}✅ No custom VPCs${NC}"
else
  echo -e "   ${YELLOW}ℹ️  Custom VPCs exist:${NC}"
  echo "$VPCS" | while read line; do
    echo "   → $line"
  done
  echo "   💰 Cost: Free (VPC itself is free)"
fi

echo ""

# =====================
# CHECK S3 BUCKETS
# =====================
echo "🪣 S3 Buckets:"
S3_BUCKETS=$(aws s3 ls | grep "steadystackai")
if [ -z "$S3_BUCKETS" ]; then
  echo -e "   ${GREEN}✅ No SteadyStackAI S3 buckets${NC}"
else
  echo -e "   ${YELLOW}ℹ️  Buckets found:${NC}"
  echo "$S3_BUCKETS" | while read line; do
    echo "   → $line"
  done
  echo "   💰 Cost: ~\$0.023/GB/month (minimal)"
fi

echo ""

# =====================
# CHECK ECR REPOS
# =====================
echo "🐳 ECR Repositories:"
ECR_REPOS=$(aws ecr describe-repositories \
  --region eu-west-1 \
  --query 'repositories[*].repositoryName' \
  --output text 2>/dev/null)

if [ -z "$ECR_REPOS" ]; then
  echo -e "   ${GREEN}✅ No ECR repositories${NC}"
else
  echo -e "   ${YELLOW}ℹ️  Repositories:${NC}"
  for repo in $ECR_REPOS; do
    echo "   → $repo"
  done
  echo "   💰 Cost: Free for first 500MB/month"
fi

echo ""

# =====================
# COST SUMMARY
# =====================
echo "================================================"
echo "💰 ESTIMATED HOURLY COST SUMMARY"
echo "================================================"

HOURLY_COST=$TOTAL_COST
DAILY_COST=$(echo "$HOURLY_COST * 24" | bc)
MONTHLY_COST=$(echo "$DAILY_COST * 30" | bc)

echo "Per hour:  \$$HOURLY_COST"
echo "Per day:   \$$DAILY_COST"
echo "Per month: \$$MONTHLY_COST"
echo ""

# =====================
# WARNINGS
# =====================
if [ $WARNINGS -gt 0 ]; then
  echo "================================================"
  echo -e "${RED}⚠️  WARNING: $WARNINGS billable resource(s) running!${NC}"
  echo "================================================"
  echo ""
  echo "To stop all charges run:"
  echo ""
  echo "Option 1 - GitHub Actions (recommended):"
  echo "→ Go to github.com/Venky0410/steadystackAI"
  echo "→ Actions → SteadyStackAI Platform Setup"
  echo "→ Run workflow → destroy"
  echo ""
  echo "Option 2 - Manual CloudShell:"
  echo "→ cd ~/steadystackAI/infrastructure/terraform"
  echo "→ terraform destroy -auto-approve"
  echo ""
  echo -e "${RED}⚠️  Don't forget to destroy when done!${NC}"
else
  echo "================================================"
  echo -e "${GREEN}✅ NO BILLABLE RESOURCES RUNNING!${NC}"
  echo -e "${GREEN}💰 You are not being charged!${NC}"
  echo "================================================"
fi

echo ""
echo "================================================"
echo "Run this script anytime: ./check-resources.sh"
echo "================================================"