# Lab 02 — Câu 1: Terraform + GitHub Actions + Checkov

## Mục tiêu
Tự động hóa kiểm thử và triển khai hạ tầng Terraform của Lab 01 bằng GitHub Actions, kèm quét bảo mật Checkov.

## Pipeline stages
1. **validate** — `terraform fmt -check`, `terraform init -backend=false`, `terraform validate`
2. **security-scan** — Checkov quét toàn bộ module Terraform, upload SARIF vào GitHub Security
3. **plan** — chỉ chạy ở pull request, comment kết quả plan vào PR
4. **apply** — chỉ chạy khi merge vào `main`, sử dụng GitHub Environment `production` để bảo vệ bằng manual approval

## Yêu cầu cấu hình GitHub
- **Secrets**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- **Environment**: tạo environment `production`, bật required reviewers
- **Branch protection**: yêu cầu các job `validate` và `security-scan` pass trước khi merge

## File `ci.tfvars`
Tạo file này (không commit) hoặc dùng GitHub Secrets để inject runtime:
```
my_ip    = "0.0.0.0/32"
key_name = "nt548-keypair"
```

## Tham chiếu Checkov
- Quy tắc đã skip: `CKV_AWS_8` (EBS encryption nếu đã set), `CKV_AWS_135` (EBS optimized)
- Báo cáo SARIF tự động hiển thị tại tab **Security → Code scanning** của repo

