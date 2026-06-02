# NT548 — DevOps Labs: AWS Infrastructure & Microservices CI/CD

> Bài tập thực hành môn **Công nghệ DevOps và Ứng dụng (NT548)** — Trường ĐH Công nghệ Thông tin, Khoa Mạng máy tính và Truyền thông.
> **GVHD:** ThS. Lê Anh Tuấn

Repository này chứa mã nguồn cho 2 bài lab:

| Lab | Nội dung | Công cụ chính |
|-----|----------|---------------|
| **Lab 01** | Quản lý hạ tầng AWS bằng IaC | Terraform, CloudFormation |
| **Lab 02** | Tự động hóa CI/CD cho hạ tầng + microservices | GitHub Actions, AWS CodePipeline, Jenkins, Docker, Kubernetes, SonarQube, Trivy |

---

## 📂 Cấu trúc repository

```
devops-aws-microservices/
├── lab01/
│   ├── terraform/              # Lab 1 — Terraform IaC
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── modules/
│   │       ├── vpc/
│   │       ├── subnet/
│   │       ├── internet_gateway/
│   │       ├── nat_gateway/
│   │       ├── route_table/
│   │       ├── security_group/
│   │       └── ec2/
│   ├── cloudformation/         # Lab 1 — CloudFormation IaC
│   │   ├── main.yaml
│   │   ├── parameters.json
│   │   └── templates/
│   └── tests/                  # Test cases cho Lab 1
│       ├── terraform/
│       └── cloudformation/
│
├── lab02/
│   ├── terraform/              # Câu 1 — Terraform code (re-use)
│   ├── cloudformation/         # Câu 2 — CloudFormation code (re-use)
│   ├── jenkins/                # Câu 3 — Jenkinsfile + setup
│   ├── k8s/                    # Câu 3 — Kubernetes manifests
│   └── microservices/          # Câu 3 — App mẫu (Node.js + Python)
│       ├── service-a/
│       ├── service-b/
│       └── frontend/
│
├── .github/workflows/          # Câu 1 Lab 02 — GitHub Actions workflow
│   └── terraform.yml
│
├── docs/                       # Tài liệu, báo cáo, screenshots
│   ├── BaoCao_Lab01_Nhom.docx
│   ├── BaoCao_Lab02_Nhom.docx
│   ├── PHAN_CONG_NHOM.md
│   └── screenshots/
│
├── .gitignore
└── README.md
```

---

## 👥 Thành viên nhóm

| STT | Họ và tên | MSSV | Vai trò |
|-----|-----------|------|---------|
| 1 | `Nguyễn Lê Như Thuận` | `23521551` | Terraform Lead — Lab 01 (TF) + Lab 02 Câu 1 |
| 2 | `Nguyễn Cao Thông` | `23521524` | CloudFormation Lead — Lab 01 (CFN) + Lab 02 Câu 2 |
| 3 | `Dương Thanh Huyền` | `23520659` | Jenkins & K8s Lead — Lab 02 Câu 3 (chính) |
| 4 | `Võ Trần Việt Tiến` | `23521590` | Microservices & Security Lead — Lab 02 Câu 3 (phụ) |
| 5 | `Đoàn Thanh Thảo` | `23521466` | Coordinator & Documentation Lead |


---

## ⚙️ Yêu cầu môi trường

### Tools cần cài đặt

| Tool | Phiên bản | Dùng cho |
|------|-----------|----------|
| AWS CLI | >= 2.0 | Tương tác AWS |
| Terraform | >= 1.5 | Lab 01 + Lab 02 Câu 1 |
| Git | latest | Version control |
| Docker | >= 20 | Lab 02 Câu 3 |
| kubectl | >= 1.27 | Lab 02 Câu 3 |
| minikube hoặc kind | latest | Lab 02 Câu 3 (K8s local) |
| Node.js | >= 18 | Lab 02 service-a |
| Python | >= 3.10 | Lab 02 service-b |
| Java | 17 | SonarQube + Jenkins |
| jq | latest | Test scripts |

### AWS account

- 1 account dùng chung cho 5 thành viên (mỗi người 1 IAM user)
- Region mặc định: `ap-southeast-1` (Singapore)
- S3 bucket cho Terraform backend: `nt548-tfstate-<groupID>`

---

## 🚀 Cách chạy

### Lab 01 — Terraform

```bash
cd lab01/terraform
cp terraform.tfvars.example terraform.tfvars  # điền MyIP, KeyName...
terraform init
terraform plan
terraform apply
# Sau khi test xong:
terraform destroy
```

Chi tiết: xem [`lab01/terraform/README.md`](lab01/terraform/README.md).

### Lab 01 — CloudFormation

```bash
cd lab01/cloudformation
aws cloudformation deploy \
  --template-file main.yaml \
  --stack-name nt548-lab01 \
  --parameter-overrides file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
# Test
bash ../tests/cloudformation/run-cfn-tests.sh
# Cleanup
aws cloudformation delete-stack --stack-name nt548-lab01
```

Chi tiết: xem [`lab01/cloudformation/README.md`](lab01/cloudformation/README.md).

### Lab 02 — Câu 1: Terraform + GitHub Actions

```bash
# Setup secrets trên GitHub repo:
#   AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
# Push code lên branch `develop` hoặc `main` để trigger workflow.
```

Workflow: [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml)

### Lab 02 — Câu 2: CloudFormation + AWS CodePipeline

```bash
# Push code lên CodeCommit repo
# Pipeline tự động: Source → Build (cfn-lint + Taskcat) → Deploy
```

Chi tiết: xem [`lab02/cloudformation/README.md`](lab02/cloudformation/README.md).

### Lab 02 — Câu 3: Jenkins CI/CD cho microservices

```bash
# Khởi động Jenkins
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts

# Khởi động SonarQube
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# Khởi động minikube
minikube start

# Tạo pipeline trong Jenkins, point tới Jenkinsfile:
#   lab02/jenkins/Jenkinsfile
```

Chi tiết: xem [`lab02/jenkins/README.md`](lab02/jenkins/README.md).

---

## 📊 Kiểm tra kết quả

| Câu | Kết quả mong đợi |
|-----|------------------|
| Lab 01 — Terraform | `terraform apply` thành công + SSH vào EC2 + ping internet từ Private EC2 |
| Lab 01 — CloudFormation | Stack `CREATE_COMPLETE` + cùng test SSH như trên |
| Lab 02 Câu 1 | GitHub Actions workflow ✓ + Checkov pass + AWS resource tạo |
| Lab 02 Câu 2 | CodePipeline ✓ tất cả stages + cfn-lint + Taskcat pass |
| Lab 02 Câu 3 | Jenkins pipeline ✓ + SonarQube Quality Gate pass + Trivy không CVE Critical + pod Running |

---

## 📝 Báo cáo

- 📄 [Báo cáo Lab 01](docs/BaoCao_Lab01_Nhom.docx)
- 📄 [Báo cáo Lab 02](docs/BaoCao_Lab02_Nhom.docx)

---

## 📅 Timeline

| Ngày | Việc |
|------|------|
| 20/05/2026 | Setup repo + skeleton; bắt đầu Lab 1 |
| 21/05/2026 | Hoàn thành Lab 1 + test cases; bắt đầu Lab 2 |
| 22/05/2026 | Hoàn thành 3 câu Lab 2; viết báo cáo |
| 23/05/2026 | Review chéo, finalize, nộp bài |

---

## 📜 License

MIT — for educational purposes only.
