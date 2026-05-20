# Lab 01 — Terraform IaC

Triển khai hạ tầng AWS bằng Terraform: VPC, Subnets, IGW, NAT Gateway, Route Tables, EC2, Security Groups.

## Cấu trúc

```
terraform/
├── main.tf                  # Root: gọi các module
├── variables.tf             # Biến đầu vào
├── outputs.tf               # Output sau khi apply
├── providers.tf             # AWS provider + backend
├── terraform.tfvars.example # Mẫu biến (đổi tên thành .tfvars)
└── modules/
    ├── vpc/
    ├── subnet/
    ├── internet_gateway/
    ├── nat_gateway/
    ├── route_table/
    ├── security_group/
    └── ec2/
```

## Yêu cầu

- Terraform >= 1.5
- AWS CLI đã `aws configure`
- Đã tạo Key Pair trong AWS Console (region `ap-southeast-1`)

## Cách chạy

```bash
# 1. Chuẩn bị biến
cp terraform.tfvars.example terraform.tfvars
# Mở terraform.tfvars, sửa my_ip + key_name

# 2. Init + plan + apply
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

# 3. Test (xem outputs)
terraform output
ssh -i ~/.ssh/<key_name>.pem ec2-user@$(terraform output -raw public_ec2_public_ip)

# 4. Cleanup
terraform destroy
```

## Test cases

Xem [`../tests/terraform/run-tests.sh`](../tests/terraform/run-tests.sh).

## Người phụ trách

**TV1 — Terraform Lead**
