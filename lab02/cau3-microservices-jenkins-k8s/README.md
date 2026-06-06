# Câu 3 - CI/CD Pipeline cho ứng dụng Microservices với GitHub Actions và Kubernetes

## Mục lục

- [Tổng quan](#tổng-quan)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Cài đặt môi trường](#cài-đặt-môi-trường)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Cấu hình GitHub Secrets](#cấu-hình-github-secrets)
- [Chạy pipeline](#chạy-pipeline)
- [Kiểm tra kết quả triển khai](#kiểm-tra-kết-quả-triển-khai)
- [Mô tả các stages](#mô-tả-các-stages)

---

## Tổng quan

Pipeline CI/CD tự động hóa toàn bộ quy trình build, kiểm tra và triển khai ứng dụng microservices gồm hai service:

- **service-a**: Viết bằng Node.js, lắng nghe cổng 3000
- **service-b**: Viết bằng Python (Flask), lắng nghe cổng 5000

Pipeline gồm 8 stages chạy tuần tự, được triển khai lên cụm Kubernetes (Minikube) thông qua self-hosted runner.

---

## Yêu cầu môi trường

### Máy chạy self-hosted runner (Stage 8 - Deploy)

| Công cụ | Phiên bản tối thiểu |
|---|---|
| Windows | 10 trở lên |
| Docker Desktop | 4.x trở lên |
| Minikube | 1.32 trở lên |
| kubectl | 1.28 trở lên |
| Node.js | 20 trở lên |

### GitHub Actions (Stages 1-7)

Các stages 1-7 chạy trên GitHub-hosted runner (ubuntu-latest), không yêu cầu cài đặt thêm.

---

## Cài đặt môi trường

### 1. Cài đặt Minikube

Tải và cài đặt Minikube theo hướng dẫn tại https://minikube.sigs.k8s.io/docs/start

Khởi động cụm:

```bash
minikube start
minikube status
```

Bật ingress addon:

```bash
minikube addons enable ingress
```

### 2. Cài đặt self-hosted runner

Tạo thư mục runner:

```powershell
mkdir C:\actions-runner
cd C:\actions-runner
```

Tải runner:

```powershell
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-win-x64-2.317.0.zip -OutFile actions-runner-win-x64.zip
```

Giải nén:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-x64.zip", "$PWD")
```

Đăng ký runner với repo (lấy token tại Settings > Actions > Runners > New self-hosted runner):

```powershell
.\config.cmd --url https://github.com/DoanThao013/devops-aws-microservices --token <TOKEN>
```

Khi được hỏi, điền các thông tin sau:

```
Runner group:  Enter (mặc định)
Runner name:   windows-local
Labels:        self-hosted,windows,minikube
Work folder:   Enter (mặc định)
```

Chọn chạy như Windows Service khi được hỏi (nhấn Y), runner sẽ tự khởi động cùng máy.

### 3. Cấu hình ExecutionPolicy cho PowerShell

```powershell
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

---

## Cấu trúc thư mục

```
lab02/cau3-microservices-jenkins-k8s/
├── service-a/
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   │   └── index.js
│   └── test/
│       └── index.test.js
├── service-b/
│   ├── Dockerfile
│   ├── app.py
│   ├── requirements.txt
│   └── test_app.py
├── k8s/
│   ├── 00-namespace.yaml
│   ├── 10-service-a.yaml
│   ├── 20-service-b.yaml
│   └── 30-ingress.yaml
├── sonar/
│   └── sonar-project.properties
└── docker-compose.yml

.github/
└── workflows/
    └── lab02_cau3_cicd.yml
```

---

## Cấu hình GitHub Secrets

Vào repo > Settings > Secrets and variables > Actions, thêm các secrets sau:

| Secret | Mô tả |
|---|---|
| DOCKERHUB_USERNAME | Tên đăng nhập DockerHub |
| DOCKERHUB_TOKEN | Access token DockerHub |
| SONAR_TOKEN | Token xác thực SonarCloud |

### Cách tạo DOCKERHUB_TOKEN

Đăng nhập DockerHub > Account Settings > Security > New Access Token.

Đặt tên token, chọn quyền Read/Write/Delete, copy và dán vào GitHub Secrets.

### Cách tạo SONAR_TOKEN

Đăng nhập SonarCloud > Avatar góc trên phải > My Account > Security > Generate Tokens.

Nhập tên token (VD: `github-actions-token`), chọn loại User Token, copy và dán vào GitHub Secrets.

---

## Chạy pipeline

### Tự động

Pipeline tự động kích hoạt khi có push lên branch `main` hoặc `develop` với thay đổi trong thư mục `lab02/cau3-microservices-jenkins-k8s/`.

### Thủ công

Vào GitHub > Actions > Microservices CI/CD Pipeline > Run workflow, chọn branch và nhấn Run workflow.

### Lưu ý trước khi chạy

Đảm bảo máy chạy self-hosted runner đang bật và Minikube đang chạy:

```powershell
minikube status
kubectl get nodes
```

---

## Kiểm tra kết quả triển khai

### Kiểm tra pods

```bash
kubectl get pods -n nt548-gr03
```

Kết quả mong đợi: tất cả pods ở trạng thái Running.

```
NAME                         READY   STATUS    RESTARTS   AGE
service-a-xxxxxxxxx-xxxxx    1/1     Running   0          ...
service-a-xxxxxxxxx-xxxxx    1/1     Running   0          ...
service-b-xxxxxxxxx-xxxxx    1/1     Running   0          ...
service-b-xxxxxxxxx-xxxxx    1/1     Running   0          ...
```

### Kiểm tra services

```bash
kubectl get svc -n nt548-gr03
```

### Kiểm tra deployments

```bash
kubectl get deployments -n nt548-gr03
```

Kết quả mong đợi: cả hai deployments đều ở trạng thái READY 2/2.

### Kiểm tra image đang chạy

```bash
kubectl get deployment service-a -n nt548-gr03 -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get deployment service-b -n nt548-gr03 -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Truy cập service-a qua NodePort

```bash
minikube service service-a -n nt548-gr03 --url
```

Mở URL trả về trên trình duyệt để kiểm tra endpoint `/health`.

### Kiểm tra DockerHub

Truy cập https://hub.docker.com/r/thanhhuyen24/service-a và https://hub.docker.com/r/thanhhuyen24/service-b để xác nhận images đã được push với đúng tag.

---

## Mô tả các stages

| Stage | Tên | Mô tả | Runner |
|---|---|---|---|
| 1 | Checkout Code | Lấy source code từ GitHub | ubuntu-latest |
| 2 | Build Docker Images | Build image cho service-a và service-b, tag theo commit SHA | ubuntu-latest |
| 3 | Unit Test | Chạy Jest cho service-a, pytest cho service-b | ubuntu-latest |
| 4 | SonarQube Analysis | Quét chất lượng mã nguồn với SonarCloud | ubuntu-latest |
| 5 | Push Images to DockerHub | Đẩy images lên DockerHub registry | ubuntu-latest |
| 6 | Quality Gate | Kiểm tra kết quả pass/fail từ SonarCloud | ubuntu-latest |
| 7 | Trivy Security Scan | Quét lỗ hổng bảo mật trên Docker images | ubuntu-latest |
| 8 | Deploy to Kubernetes | Triển khai lên Minikube | self-hosted (Windows) |

### Stage 3 — Unit Test

- **service-a:** Cài dependencies bằng `npm install`, chạy test bằng `npm test` (Jest + supertest).
- **service-b:** Cài dependencies bằng `pip install -r requirements.txt pytest pytest-cov`, chạy `pytest test_app.py -v --cov=. --cov-report=xml:coverage.xml`. File `coverage.xml` sinh ra sẽ được SonarCloud đọc ở Stage 4.
- Nếu bất kỳ test nào fail, pipeline dừng ngay và không tiến đến các stage tiếp theo.

### Stage 4 — SonarQube Analysis

- Sử dụng `SonarSource/sonarqube-scan-action@v6` với `fetch-depth: 0` (bắt buộc để SonarCloud đọc được toàn bộ lịch sử Git).
- Cờ `sonar.qualitygate.wait=true` khiến pipeline chờ SonarCloud xử lý xong rồi mới trả kết quả. Nếu Quality Gate **FAILED**, pipeline dừng lại với exit code 3.
- Cấu hình project đặt trong `sonar/sonar-project.properties`, token truyền qua biến môi trường `SONAR_TOKEN`.

### Stage 6 — Quality Gate

- Kiểm tra lại trạng thái Quality Gate sau khi SonarCloud hoàn tất phân tích.
- Nếu kết quả là `ERROR`, stage này báo lỗi và dừng pipeline, ngăn code kém chất lượng tiến đến bước deploy.

### Stage 7 — Trivy Security Scan

- Quét trực tiếp image từ DockerHub với tham số `severity: CRITICAL,HIGH` và `ignore-unfixed: true` (chỉ báo CVE đã có bản vá).
- `exit-code: 0` — stage chỉ cảnh báo, không dừng pipeline. Trong môi trường production nên đổi thành `exit-code: 1`.
- Kết quả thực tế: service-a phát hiện 11 lỗ hổng HIGH (đều có bản vá), service-b sạch hoàn toàn (0 CVE).