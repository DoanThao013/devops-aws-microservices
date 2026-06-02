param (
    [Parameter(Mandatory=$true)][string]$KeyPath,
    [Parameter(Mandatory=$true)][string]$PublicIP,
    [Parameter(Mandatory=$true)][string]$PrivateIP,
    [string]$Region = "ap-southeast-1",
    [string]$Prefix = "nt548-nhom03"
)

function Write-Result {
    param([string]$TestName, [bool]$IsPass, [string]$Details = "")
    Write-Host ("{0,-47}" -f $TestName) -NoNewline
    if ($IsPass) {
        Write-Host "[PASS]" -ForegroundColor Green
        if ($Details) { Write-Host "  -> $Details" -ForegroundColor DarkGray }
    } else {
        Write-Host "[FAIL]" -ForegroundColor Red
        if ($Details) { Write-Host "  -> $Details" -ForegroundColor Red }
    }
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "   GIAI DOAN 1: KIEM TRA TRANG THAI TAI NGUYEN" -ForegroundColor Cyan
Write-Host "=======================================================`n" -ForegroundColor Cyan

$vpc = aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$Prefix-vpc" --region $Region --query "Vpcs[0].State" --output text
Write-Result "1. Kiem tra mang ao VPC ($Prefix-vpc)" ($vpc -eq "available") "State: $vpc"

$pubSub = aws ec2 describe-subnets --filters "Name=tag:Name,Values=$Prefix-public-subnet" --region $Region --query "Subnets[0].State" --output text
Write-Result "2. Kiem tra Public Subnet" ($pubSub -eq "available") "State: $pubSub"

$privSub = aws ec2 describe-subnets --filters "Name=tag:Name,Values=$Prefix-private-subnet" --region $Region --query "Subnets[0].State" --output text
Write-Result "3. Kiem tra Private Subnet" ($privSub -eq "available") "State: $privSub"

$igw = aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=$Prefix-igw" --region $Region --query "InternetGateways[0].Attachments[0].State" --output text
Write-Result "4. Kiem tra Internet Gateway" ($igw -eq "available") "Attachment State: $igw"

$nat = aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=$Prefix-nat-gateway" --region $Region --query "NatGateways[0].State" --output text
Write-Result "5. Kiem tra NAT Gateway" ($nat -eq "available") "State: $nat"

$pubEc2 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$Prefix-public-ec2" --region $Region --query "Reservations[0].Instances[0].State.Name" --output text
Write-Result "6. Kiem tra Public EC2 Instance" ($pubEc2 -eq "running") "State: $pubEc2"

$privEc2 = aws ec2 describe-instances --filters "Name=tag:Name,Values=$Prefix-private-ec2" --region $Region --query "Reservations[0].Instances[0].State.Name" --output text
Write-Result "7. Kiem tra Private EC2 Instance" ($privEc2 -eq "running") "State: $privEc2"


Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "   GIAI DOAN 2: KIEM THU LUONG MANG" -ForegroundColor Cyan
Write-Host "=======================================================`n" -ForegroundColor Cyan

$sshPub = ssh -n -i $KeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@$PublicIP "echo OK" 2>&1
Write-Result "8. Truy cap SSH vao Public EC2" ([bool]($sshPub -match "OK")) "Truy cap thong suot"

$inetPub = ssh -n -i $KeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@$PublicIP "curl -s -I https://aws.amazon.com | head -n 1" 2>&1
Write-Result "9. Public EC2 ket noi ra Internet" ([bool]($inetPub -match "HTTP")) "Truy cap Internet OK"

$scp = scp -q -i $KeyPath -o StrictHostKeyChecking=no $KeyPath "ec2-user@${PublicIP}:/home/ec2-user/mykey.pem" 2>&1
$chmod = ssh -n -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$PublicIP "chmod 400 mykey.pem" 2>&1

$sshPriv = ssh -n -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$PublicIP "ssh -n -i mykey.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@$PrivateIP 'echo OK'" 2>&1
Write-Result "10. Truy cap SSH vao Private EC2 qua Bastion" ([bool]($sshPriv -match "OK")) "Jump thanh cong qua Bastion"

$inetPriv = ssh -n -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$PublicIP "ssh -n -i mykey.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@$PrivateIP 'curl -s -I https://aws.amazon.com | head -n 1'" 2>&1
Write-Result "11. Private EC2 ra Internet (qua NAT Gateway)" ([bool]($inetPriv -match "HTTP")) "NAT Gateway hoat dong hoan hao"

Write-Host "12. Kiem tra cach ly Private EC2 tu Internet   " -NoNewline
$isoTest = ssh -n -i $KeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=3 ec2-user@$PrivateIP "echo BAD" 2>&1
if (-not ($isoTest -match "BAD")) {
    Write-Host "[PASS]" -ForegroundColor Green
    Write-Host "  -> Ket noi bi tu choi (Dung thiet ke bao mat)" -ForegroundColor DarkGray
} else {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "  -> Lo hong: Co the truy cap truc tiep vao Private!" -ForegroundColor Red
}
