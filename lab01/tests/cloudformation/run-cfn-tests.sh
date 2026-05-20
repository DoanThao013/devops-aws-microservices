#!/usr/bin/env bash
# Lab 01 - CloudFormation infrastructure tests
# Verifies stack outputs and resource health
# Usage: ./run-cfn-tests.sh <stack-name> <region>

set -euo pipefail

STACK="${1:-nt548-lab01}"
REGION="${2:-ap-southeast-1}"

PASS=0
FAIL=0

check() {
  local name="$1"
  local ok="$2"
  if [[ "$ok" == "true" ]]; then
    echo "  [PASS] $name"
    PASS=$((PASS+1))
  else
    echo "  [FAIL] $name"
    FAIL=$((FAIL+1))
  fi
}

echo "=== Lab 01 CloudFormation Tests ==="
echo "Stack: $STACK | Region: $REGION"
echo

echo "[1] Parent stack status"
STATUS=$(aws cloudformation describe-stacks --region "$REGION" \
  --stack-name "$STACK" \
  --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
[[ "$STATUS" == "CREATE_COMPLETE" || "$STATUS" == "UPDATE_COMPLETE" ]] && OK=true || OK=false
echo "  Stack status: $STATUS"
check "Parent stack healthy" "$OK"

echo "[2] Nested stacks"
NESTED=$(aws cloudformation list-stacks --region "$REGION" \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
  --query "length(StackSummaries[?starts_with(StackName, '${STACK}-')])" --output text)
[[ "$NESTED" -ge 6 ]] && OK=true || OK=false
echo "  Nested stacks complete: $NESTED (expected >=6)"
check "Nested stacks deployed" "$OK"

echo "[3] Stack outputs"
OUTPUTS=$(aws cloudformation describe-stacks --region "$REGION" \
  --stack-name "$STACK" \
  --query 'Stacks[0].Outputs' --output json)

for KEY in VpcId PublicSubnetId PrivateSubnetId PublicEc2Id PrivateEc2Id; do
  VAL=$(echo "$OUTPUTS" | grep -o "\"OutputKey\": \"$KEY\"" || true)
  [[ -n "$VAL" ]] && OK=true || OK=false
  check "Output: $KEY" "$OK"
done

echo "[4] EC2 instance health"
PUB_EC2=$(aws cloudformation describe-stacks --region "$REGION" \
  --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='PublicEc2Id'].OutputValue" --output text)
if [[ -n "$PUB_EC2" ]]; then
  STATE=$(aws ec2 describe-instances --region "$REGION" \
    --instance-ids "$PUB_EC2" \
    --query 'Reservations[0].Instances[0].State.Name' --output text)
  [[ "$STATE" == "running" ]] && OK=true || OK=false
  check "Public EC2 running ($PUB_EC2)" "$OK"
fi

echo
echo "=== Result: ${PASS} passed, ${FAIL} failed ==="
exit "$FAIL"
