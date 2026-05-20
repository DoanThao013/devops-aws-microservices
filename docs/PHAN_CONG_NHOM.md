# 📋 PHÂN CÔNG CÔNG VIỆC NHÓM — NT548 DevOps Labs

**Môn học:** Công nghệ DevOps và Ứng dụng (NT548)
**Giảng viên:** ThS. Lê Anh Tuấn
**Số thành viên:** 5
**Deadline:** 23/05/2026
**Hôm nay:** 20/05/2026 (còn ~3 ngày)

---

## 📅 Timeline tổng thể

| Ngày | Mục tiêu chính |
|------|----------------|
| **Ngày 1 (20/05)** | Setup môi trường, chia nhánh Git, hoàn thành Lab 1 (Terraform + CloudFormation cơ bản) |
| **Ngày 2 (21/05)** | Hoàn thiện Lab 1, viết test cases, bắt đầu Lab 2 (CI/CD pipelines) |
| **Ngày 3 (22/05)** | Hoàn thành Lab 2, tích hợp + test toàn bộ, viết 2 báo cáo |
| **Sáng 23/05** | Review chéo, nộp bài |

---

## 👤 THÀNH VIÊN 1 (TV1) — Terraform Lead

**Tổng tải:** Lab 1 (Terraform) + Lab 2 Câu 1

### Lab 1 — Terraform code (deadline: 21/05 trưa)

- [ ] Tạo thư mục `lab01/terraform/` với cấu trúc module
- [ ] Viết `modules/vpc/` — tạo VPC + CIDR `10.0.0.0/16`
- [ ] Viết `modules/subnet/` — 1 Public Subnet (`10.0.1.0/24`) + 1 Private Subnet (`10.0.2.0/24`)
- [ ] Viết `modules/internet_gateway/` — IGW + attach vào VPC
- [ ] Viết `modules/nat_gateway/` — Elastic IP + NAT Gateway trong Public Subnet
- [ ] Viết `modules/route_table/` — Public RT (route 0.0.0.0/0 → IGW), Private RT (0.0.0.0/0 → NAT)
- [ ] Viết `modules/security_group/` — Public SG (SSH port 22 từ IP nhà), Private SG (SSH chỉ từ Public SG)
- [ ] Viết `modules/ec2/` — 1 EC2 Public (Amazon Linux 2, t2.micro, key pair), 1 EC2 Private
- [ ] File root: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars.example`, `providers.tf` (S3 backend)
- [ ] Test: `terraform init` → `plan` → `apply` → SSH thành công vào Public, từ Public SSH sang Private → `destroy`

### Lab 2 — Câu 1: GitHub Actions + Checkov (deadline: 22/05 tối)

- [ ] Copy code Terraform Lab 1 sang `lab02/terraform/`
- [ ] Viết `.github/workflows/terraform.yml`:
  - Trigger: push vào `main`/`develop`
  - Job 1: `terraform fmt` + `terraform validate`
  - Job 2: **Checkov scan** (`bridgecrewio/checkov-action@master`)
  - Job 3: `terraform plan` (manual approve trước apply)
  - Job 4: `terraform apply` (chỉ chạy khi merge vào `main`)
- [ ] Setup GitHub Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- [ ] Fix các lỗi Checkov báo (encrypt EBS, EC2 IMDSv2, SG không 0.0.0.0/0...)
- [ ] Chụp screenshot: workflow chạy xanh, Checkov report, resource trên AWS Console

### Báo cáo (deadline: 23/05 sáng)

- [ ] Viết phần **Terraform** của Báo cáo Lab 1 (mục 1.1 Terraform): mô tả module, code mẫu, screenshot deploy
- [ ] Viết phần **Câu 1** của Báo cáo Lab 2: workflow YAML, kết quả Checkov, screenshot Actions

---

## 👤 THÀNH VIÊN 2 (TV2) — CloudFormation Lead

**Tổng tải:** Lab 1 (CloudFormation) + Lab 2 Câu 2

### Lab 1 — CloudFormation template (deadline: 21/05 trưa)

- [ ] Tạo thư mục `lab01/cloudformation/`
- [ ] Viết `templates/vpc.yaml` — VPC + IGW + Default SG (Nested Stack hoặc 1 file)
- [ ] Viết `templates/subnets.yaml` — Public Subnet + Private Subnet + AZ
- [ ] Viết `templates/nat.yaml` — EIP + NAT Gateway
- [ ] Viết `templates/route-tables.yaml` — Public RT + Private RT + Associations
- [ ] Viết `templates/security-groups.yaml` — Public SG (SSH port 22) + Private SG
- [ ] Viết `templates/ec2.yaml` — Public EC2 + Private EC2 + KeyPair
- [ ] File `main.yaml` — Parent stack gọi các nested stack qua `AWS::CloudFormation::Stack`
- [ ] File `parameters.json` — input params (KeyName, MyIP, InstanceType...)
- [ ] Test: `aws cloudformation deploy` → SSH verify → `delete-stack`

### Lab 2 — Câu 2: CodePipeline + CodeBuild + cfn-lint + Taskcat (deadline: 22/05 tối)

- [ ] Copy CloudFormation Lab 1 sang `lab02/cloudformation/`
- [ ] Push code lên **AWS CodeCommit** (tạo repo)
- [ ] Viết `buildspec.yml` cho CodeBuild:
  - Install: `pip install cfn-lint taskcat`
  - Pre-build: `cfn-lint templates/*.yaml`
  - Build: `taskcat test run` (kèm `.taskcat.yml`)
- [ ] Viết `.taskcat.yml` — config test trên 1-2 region
- [ ] Tạo CodePipeline (qua Console hoặc CFN template):
  - Stage 1: Source (CodeCommit)
  - Stage 2: Build (CodeBuild với buildspec.yml trên)
  - Stage 3: Deploy (CloudFormation deploy stack)
- [ ] Chụp screenshot: pipeline chạy xanh, CodeBuild log, stack tạo thành công

### Báo cáo (deadline: 23/05 sáng)

- [ ] Viết phần **CloudFormation** của Báo cáo Lab 1: cấu trúc nested stack, parameters, screenshot
- [ ] Viết phần **Câu 2** của Báo cáo Lab 2: kiến trúc pipeline, buildspec, kết quả cfn-lint + Taskcat

---

## 👤 THÀNH VIÊN 3 (TV3) — Jenkins & Kubernetes Lead

**Tổng tải:** Test Lab 1 (Terraform side) + Lab 2 Câu 3 phần Jenkins/Docker/K8s

### Lab 1 — Test cases cho Terraform (deadline: 21/05 tối)

- [ ] Tạo thư mục `lab01/tests/terraform/`
- [ ] Viết test bash script HOẶC terratest (Go) kiểm tra:
  - VPC tồn tại đúng CIDR
  - 2 Subnet (1 Public, 1 Private) đúng AZ
  - IGW + NAT Gateway running
  - Route Table có route đúng
  - SG rule khớp yêu cầu (SSH 22, restrict IP)
  - SSH vào Public EC2 thành công
  - Từ Public EC2 SSH sang Private EC2 OK
  - Private EC2 ping internet được (qua NAT)
- [ ] Viết script `run-tests.sh` chạy tất cả

### Lab 2 — Câu 3 phần CHÍNH: Jenkins + Docker + K8s (deadline: 22/05 tối)

- [ ] Tạo thư mục `lab02/jenkins/` và `lab02/k8s/`
- [ ] Cài Jenkins (Docker container hoặc EC2 instance)
- [ ] Cấu hình Jenkins: install plugins (Docker, Kubernetes, SonarQube Scanner, Pipeline)
- [ ] Setup credentials trong Jenkins (DockerHub, kubeconfig, AWS)
- [ ] Viết `Jenkinsfile` (declarative pipeline) cho microservices của TV4:
  - Stage 1: Checkout
  - Stage 2: Build (npm/maven)
  - Stage 3: Unit test
  - Stage 4: SonarQube scan (TV4 setup server)
  - Stage 5: Build Docker image + push registry
  - Stage 6: Trivy scan image (TV4 config)
  - Stage 7: Deploy to Kubernetes (`kubectl apply`)
- [ ] Viết Kubernetes manifests trong `k8s/`: `deployment.yaml`, `service.yaml`, `ingress.yaml` cho mỗi microservice
- [ ] Setup K8s cluster: **minikube/kind local** HOẶC **EKS** (chọn minikube cho nhanh)
- [ ] Chụp screenshot: Jenkins pipeline xanh hết stages, pod running trong K8s, app truy cập được

### Báo cáo (deadline: 23/05 sáng)

- [ ] Viết phần **Test cases** của Báo cáo Lab 1
- [ ] Viết **nửa đầu Câu 3** Báo cáo Lab 2: kiến trúc Jenkins, Jenkinsfile, K8s deployment, Docker

---

## 👤 THÀNH VIÊN 4 (TV4) — Microservices & Security Lead

**Tổng tải:** Test Lab 1 (CloudFormation side) + Lab 2 Câu 3 phần microservices/SonarQube/Trivy

### Lab 1 — Test cases cho CloudFormation (deadline: 21/05 tối)

- [ ] Tạo thư mục `lab01/tests/cloudformation/`
- [ ] Chạy `cfn-lint templates/*.yaml` — fix tất cả warning
- [ ] Viết test script kiểm tra sau khi deploy stack (giống TV3 nhưng cho CFN stack):
  - `aws cloudformation describe-stacks` — Status = `CREATE_COMPLETE`
  - `aws ec2 describe-vpcs` — verify VPC tag
  - `aws ec2 describe-subnets` — đúng 2 subnet
  - `aws ec2 describe-instances` — 2 EC2 running
  - SSH connectivity test (giống TV3)
- [ ] Viết `run-cfn-tests.sh`

### Lab 2 — Câu 3 phần PHỤ: Microservices + SonarQube + Trivy (deadline: 22/05 tối)

- [ ] Tạo thư mục `lab02/microservices/` với **2-3 service đơn giản**:
  - `service-a/` — REST API Node.js Express (endpoint `/hello`)
  - `service-b/` — REST API Python Flask (endpoint `/world`)
  - (optional) `frontend/` — HTML đơn giản gọi 2 API trên
- [ ] Mỗi service có: source code + `Dockerfile` + `package.json`/`requirements.txt` + unit test cơ bản (jest/pytest)
- [ ] Viết `docker-compose.yml` test local
- [ ] Setup **SonarQube server** (Docker container) + tạo project + tokens
- [ ] Cấu hình `sonar-project.properties` cho mỗi service
- [ ] Setup **Trivy** scan image trong pipeline (TV3 tích hợp vào Jenkinsfile, TV4 cung cấp config + viết hướng dẫn)
- [ ] Test SonarQube scan local — đảm bảo có report (bug, code smell, coverage)
- [ ] Test Trivy scan image local — có report CVE
- [ ] Chụp screenshot: SonarQube dashboard, Trivy report

### Báo cáo (deadline: 23/05 sáng)

- [ ] Viết phần **Test cases CloudFormation** của Báo cáo Lab 1
- [ ] Viết **nửa sau Câu 3** Báo cáo Lab 2: microservices structure, SonarQube setup + report, Trivy scan kết quả

---

## 👤 THÀNH VIÊN 5 (TV5) — Coordinator, AWS Admin & Documentation Lead

**Tổng tải:** Repo setup, AWS account admin, viết 2 báo cáo Word, README

### Setup ban đầu (deadline: 20/05 tối — ƯU TIÊN CAO)

- [ ] Tạo GitHub repo `nt548-lab` (private hoặc public)
- [ ] Setup cấu trúc thư mục:

  ```
  nt548-lab/
  ├── lab01/
  │   ├── terraform/
  │   ├── cloudformation/
  │   └── tests/
  ├── lab02/
  │   ├── terraform/         (TV1)
  │   ├── cloudformation/    (TV2)
  │   ├── jenkins/           (TV3)
  │   ├── k8s/               (TV3)
  │   ├── microservices/     (TV4)
  │   └── .github/workflows/ (TV1)
  ├── docs/
  │   ├── BaoCao_Lab01.docx
  │   └── BaoCao_Lab02.docx
  ├── .gitignore
  └── README.md
  ```

- [ ] Viết `.gitignore` (terraform state, .env, node_modules, *.pem...)
- [ ] Tạo branch protection: `main` chỉ merge qua PR + 1 approval
- [ ] Tạo 5 IAM user trong AWS (mỗi TV 1 user) với policy phù hợp
- [ ] Phát credentials cho từng TV
- [ ] Tạo S3 bucket `nt548-tfstate-<groupID>` cho Terraform backend
- [ ] Tạo GitHub Issues từ checklist này — assign từng người

### Hỗ trợ kỹ thuật (xuyên suốt 21-22/05)

- [ ] Review PR của các TV, merge vào `main` khi đủ điều kiện
- [ ] Hỗ trợ debug khi TV nào kẹt (đặc biệt TV3 phần K8s thường khó)
- [ ] Quản lý cost: theo dõi AWS Cost Explorer, nhắc team destroy resource sau test
- [ ] Backup: chụp lại tất cả screenshot kết quả của các TV vào `docs/screenshots/`

### Viết Báo cáo Word (deadline: 23/05 sáng — VIỆC CHÍNH)

- [ ] **Báo cáo Lab 1 (`BaoCao_Lab01.docx`)** theo mẫu PDF:
  - Trang bìa, thông tin nhóm + MSSV 5 thành viên
  - Bảng phân chia công việc (dùng nội dung này)
  - Mục B - Báo cáo chi tiết: tổng hợp phần TV1 (Terraform), TV2 (CFN), TV3+TV4 (test cases)
  - Phần kết luận, khó khăn, đề xuất
- [ ] **Báo cáo Lab 2 (`BaoCao_Lab02.docx`)** theo mẫu PDF:
  - Tương tự Lab 1
  - Câu 1: nội dung TV1 viết
  - Câu 2: nội dung TV2 viết
  - Câu 3: nội dung TV3 + TV4 viết (gộp lại mạch lạc)
- [ ] Viết `README.md` tổng (cho cả repo): giới thiệu, cách clone, prerequisite, hướng dẫn chạy từng phần, link tới sub-README
- [ ] Format thống nhất: font, screenshot có caption, mục lục tự động

### Final review (23/05 sáng)

- [ ] Review chéo 2 báo cáo cùng cả nhóm
- [ ] Convert Word sang PDF
- [ ] Nộp bài + push final commit

---

## ⚠️ Lưu ý quan trọng khi dùng chung 1 AWS account

Vì 5 người dùng chung tài khoản, để tránh xung đột resource:

1. **Quy ước đặt tên:** Mỗi người prefix tên resource theo MSSV/tên: `tv1-vpc`, `tv2-vpc`, `tv3-jenkins`...
2. **Region khác nhau** (nếu được): TV1 dùng `us-east-1`, TV2 dùng `ap-southeast-1`...
3. **Mỗi người 1 IAM user** riêng (TV5 setup), không share root credentials
4. **Terraform state file:** Dùng S3 backend với key path khác nhau cho mỗi người
5. **Destroy ngay sau khi test xong** để tránh tốn tiền (NAT Gateway ~$0.045/h)

---

## 📋 Checklist deadline 23/05

- [ ] **20/05 tối:** TV1 + TV2 đã có code Terraform/CFN chạy được local; TV5 đã setup repo + IAM
- [ ] **21/05 tối:** Lab 1 xong hoàn toàn (deploy thành công + có test). Bắt đầu Lab 2.
- [ ] **22/05 tối:** Cả 3 câu của Lab 2 chạy được. Bắt đầu viết báo cáo.
- [ ] **23/05 sáng:** Review chéo, finalize 2 báo cáo Word + 2 README.md, nộp.

---

## 📊 Tóm tắt khối lượng công việc

| TV | Vai trò | Code (giờ) | Test (giờ) | Báo cáo (giờ) | Tổng |
|----|---------|-----------|-----------|---------------|------|
| TV1 | Terraform Lead | ~12 | 2 | 3 | **~17h** |
| TV2 | CloudFormation Lead | ~12 | 2 | 3 | **~17h** |
| TV3 | Jenkins & K8s Lead | ~10 | 4 | 3 | **~17h** |
| TV4 | Microservices & Security | ~10 | 3 | 3 | **~16h** |
| TV5 | Coordinator & Docs | ~3 (setup) | ~6 (hỗ trợ) | ~8 (báo cáo) | **~17h** |

Tải khá đều, mỗi người ~16-17h trong 3 ngày (tức ~5-6h/ngày).

---

## 🔗 Liên kết phụ thuộc giữa các thành viên

```
TV5 (setup repo + IAM)
   ↓
TV1 ─────┐
TV2 ─────┼──→ Lab 1 hoàn thành (21/05)
TV3 ─────┤    (TV3 test sau khi TV1 deploy xong)
TV4 ─────┘    (TV4 test sau khi TV2 deploy xong)
   ↓
TV1 → Lab 2 Câu 1 (GitHub Actions)
TV2 → Lab 2 Câu 2 (CodePipeline)
TV4 → Microservices code ──→ TV3 → Jenkinsfile + K8s deploy
   ↓
TV5 tổng hợp → 2 Báo cáo Word (23/05)
```
