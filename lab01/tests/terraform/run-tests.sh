#!/usr/bin/env bash
# Lab 01 - Terraform infrastructure tests
# Verifies that VPC, Subnets, IGW, NAT, Route Tables, EC2, Security Groups exist
# Usage: ./run-tests.sh <name-prefix> <region>

set -euo pipefail

PREFIX="${1:-nt548}"
REGION="${2:-ap-southeast-1}"

PASS=0
FAIL=0

check() {
  local name="$1"
  local count="$2"
  local expected="$3"
  if [[ "$count" -ge "$expected" ]]; then
    echo "  [PASS] $name (found $count)"
    PASS=$((PASS+1))
  else
    echo "  [FAIL] $name (expected >=$expected, found $count)"
    FAIL=$((FAIL+1))
  fi
}

echo "=== Lab 01 Terraform Tests ==="
echo "Prefix: $PREFIX | Region: $REGION"
echo

echo "[1] VPC"
VPC_CNT=$(aws ec2 describe-vpcs --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-vpc" \
  --query 'length(Vpcs)' --output text)
check "VPC ${PREFIX}-vpc" "$VPC_CNT" 1

echo "[2] Subnets"
PUB_CNT=$(aws ec2 describe-subnets --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-public-subnet" \
  --query 'length(Subnets)' --output text)
PRI_CNT=$(aws ec2 describe-subnets --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-private-subnet" \
  --query 'length(Subnets)' --output text)
check "Public Subnet" "$PUB_CNT" 1
check "Private Subnet" "$PRI_CNT" 1

echo "[3] Internet Gateway"
IGW_CNT=$(aws ec2 describe-internet-gateways --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-igw" \
  --query 'length(InternetGateways)' --output text)
check "IGW" "$IGW_CNT" 1

echo "[4] NAT Gateway"
NAT_CNT=$(aws ec2 describe-nat-gateways --region "$REGION" \
  --filter "Name=tag:Name,Values=${PREFIX}-nat" "Name=state,Values=available" \
  --query 'length(NatGateways)' --output text)
check "NAT Gateway" "$NAT_CNT" 1

echo "[5] Route Tables"
RT_PUB=$(aws ec2 describe-route-tables --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-public-rt" \
  --query 'length(RouteTables)' --output text)
RT_PRI=$(aws ec2 describe-route-tables --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-private-rt" \
  --query 'length(RouteTables)' --output text)
check "Public Route Table" "$RT_PUB" 1
check "Private Route Table" "$RT_PRI" 1

echo "[6] Security Groups"
SG_PUB=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-public-sg" \
  --query 'length(SecurityGroups)' --output text)
SG_PRI=$(aws ec2 describe-security-groups --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-private-sg" \
  --query 'length(SecurityGroups)' --output text)
check "Public SG" "$SG_PUB" 1
check "Private SG" "$SG_PRI" 1

echo "[7] EC2 Instances"
EC2_PUB=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-public-ec2" "Name=instance-state-name,Values=running" \
  --query 'length(Reservations[].Instances[])' --output text)
EC2_PRI=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-private-ec2" "Name=instance-state-name,Values=running" \
  --query 'length(Reservations[].Instances[])' --output text)
check "Public EC2 (running)" "$EC2_PUB" 1
check "Private EC2 (running)" "$EC2_PRI" 1

echo
echo "=== Result: ${PASS} passed, ${FAIL} failed ==="
exit "$FAIL"
