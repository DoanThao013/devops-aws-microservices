param(
    [string]$KeyName   = "nt548-key",
    [string]$PublicIP  = "",
    [string]$PrivateIP = ""
)
 
$PassCount = 0
$FailCount = 0
 
function Pass($msg)   { Write-Host "[PASS] $msg" -ForegroundColor Green;  $script:PassCount++ }
function Fail($msg)   { Write-Host "[FAIL] $msg" -ForegroundColor Red;    $script:FailCount++ }
function Info($msg)   { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Header($msg) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Yellow
    Write-Host "  $msg" -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Yellow
}
 
if (-not $PublicIP -or -not $PrivateIP) {
    $TfDir = Resolve-Path "$PSScriptRoot\..\..\terraform"
    $PublicIP  = & terraform -chdir="$TfDir" output -raw public_ec2_public_ip  2>$null
    $PrivateIP = & terraform -chdir="$TfDir" output -raw private_ec2_private_ip 2>$null
}
 
if (-not $PublicIP -or -not $PrivateIP) {
    Write-Host "ERROR: Missing IPs. Usage: .\run-tests.ps1 -KeyName nt548-key -PublicIP x.x.x.x -PrivateIP 10.0.2.x" -ForegroundColor Red
    exit 1
}
 
$KeyPath = "$HOME\.ssh\$KeyName.pem"
Info "Public  EC2 IP : $PublicIP"
Info "Private EC2 IP : $PrivateIP"
Info "Key Path       : $KeyPath"
 
$SO = @("-i", $KeyPath, "-o", "StrictHostKeyChecking=no", "-o", "ConnectTimeout=10", "-o", "BatchMode=yes")
 
Header "TEST 1 - AWS CLI Connectivity"
try {
    $id = aws sts get-caller-identity --output json 2>$null | ConvertFrom-Json
    if ($id.Account) { Pass "AWS CLI connected - Account: $($id.Account)" }
    else { Fail "AWS CLI not configured" }
} catch { Fail "AWS CLI not configured" }
 
Header "TEST 2 - VPC Existence"
try {
    $TfDir = Resolve-Path "$PSScriptRoot\..\..\terraform"
    $VpcId = & terraform -chdir="$TfDir" output -raw vpc_id 2>$null
    if ($VpcId) {
        $state = aws ec2 describe-vpcs --vpc-ids $VpcId --query "Vpcs[0].State" --output text 2>$null
        if ($state -eq "available") { Pass "VPC $VpcId is available" }
        else { Fail "VPC state: $state" }
    } else { Fail "Cannot get VPC ID" }
} catch { Fail "Error: $_" }
 
Header "TEST 3 - SSH to Public EC2"
try {
    $r = & ssh @SO "ec2-user@$PublicIP" "echo ok" 2>$null
    if ($r -match "ok") { Pass "SSH to Public EC2 ($PublicIP) succeeded" }
    else { Fail "SSH to Public EC2 failed - check key and Security Group" }
} catch { Fail "SSH failed: $_" }
 
Header "TEST 4 - Public EC2 Internet Access"
try {
    $ip = & ssh @SO "ec2-user@$PublicIP" "curl -s --max-time 5 https://checkip.amazonaws.com" 2>$null
    if ($ip) { Pass "Public EC2 Internet OK - external IP: $($ip.Trim())" }
    else { Fail "Public EC2 cannot reach Internet" }
} catch { Fail "Test failed: $_" }
 
Header "TEST 5 - SSH Jump to Private EC2"
try {
    & scp @SO $KeyPath "ec2-user@${PublicIP}:~/.ssh/id_rsa" 2>$null
    & ssh @SO "ec2-user@$PublicIP" "chmod 400 ~/.ssh/id_rsa" 2>$null
    $r = & ssh @SO "ec2-user@$PublicIP" "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@$PrivateIP 'echo ok'" 2>$null
    if ($r -match "ok") { Pass "SSH Public -> Private EC2 ($PrivateIP) succeeded" }
    else { Fail "SSH jump to Private EC2 failed" }
} catch { Fail "Test failed: $_" }
 
Header "TEST 6 - Private EC2 Internet via NAT"
try {
    $r = & ssh @SO "ec2-user@$PublicIP" "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@$PrivateIP 'curl -s --max-time 10 https://checkip.amazonaws.com'" 2>$null
    if ($r) { Pass "Private EC2 NAT OK - external IP: $($r.Trim())" }
    else { Fail "Private EC2 cannot reach Internet via NAT" }
} catch { Fail "Test failed: $_" }
 
Header "TEST 7 - Private EC2 NOT reachable from Internet"
try {
    $r = & ssh -i $KeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes "ec2-user@$PrivateIP" "echo ok" 2>$null
    if ($r -match "ok") { Fail "Private EC2 is directly accessible - security risk!" }
    else { Pass "Private EC2 is NOT directly accessible from Internet (correct)" }
} catch { Pass "Private EC2 is NOT directly accessible from Internet (correct)" }
 
Header "SUMMARY"
Write-Host "Passed: $PassCount  |  Failed: $FailCount"
if ($FailCount -eq 0) {
    Write-Host "All tests passed! Infrastructure is healthy." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some tests failed. Check output above." -ForegroundColor Red
    exit 1
}