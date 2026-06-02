# Lab 01 — CloudFormation IaC

Triển khai cùng hạ tầng AWS như Terraform nhưng dùng CloudFormation **nested stacks**.

## Cấu trúc

```
cloudformation/
├── main.yaml                  # Parent stack
├── parameters.json            # Tham số đầu vào
└── templates/
    ├── vpc.yaml
    ├── subnets.yaml
    ├── nat.yaml
    ├── route-tables.yaml
    ├── security-groups.yaml
    └── ec2.yaml
```

## Cách chạy

```bash
# 1. Tạo S3 bucket chứa nested templates
aws s3 mb s3://nt548-cfn-templates-nhom03 --region ap-southeast-1

# 2. Upload nested templates lên S3
aws s3 cp templates/ s3://nt548-cfn-templates-nhom03/templates/ --recursive

# 3. Sửa parameters.json: TemplateBucket, MyIp, KeyName
# 4. Deploy
aws cloudformation deploy \
  --template-file main.yaml \
  --stack-name nt548-lab01 \
  --parameter-overrides file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ap-southeast-1

# 5. Lấy outputs
aws cloudformation describe-stacks \
  --stack-name nt548-lab01 \
  --query 'Stacks[0].Outputs'
