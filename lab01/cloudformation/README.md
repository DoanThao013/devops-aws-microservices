# Lab 01 - Triển khai Hạ tầng AWS với CloudFormation
Thư mục này chứa toàn bộ mã nguồn AWS CloudFormation để tự động hóa việc cấp phát hạ tầng mạng cơ bản. Kiến trúc được thiết kế tuân thủ các tiêu chuẩn bảo mật phân tách Public/Private Subnet, sử dụng mô hình Bastion Host và NAT Gateway thông qua kỹ thuật Nested Stacks.

## Cấu trúc thư mục
Dự án được phân chia thành các file template độc lập để dễ quản lý và tăng tính tái sử dụng:

cloudformation/
├── main.yaml                # Root file: Gọi và truyền tham số cho các stack con
├── parameters.json          # File khai báo các giá trị tham số đầu vào 
├── run-tests.ps1            # Kịch bản PowerShell tự động kiểm thử luồng mạng 
└── templates/               # Thư mục chứa cấu hình chi tiết từng dịch vụ 
    ├── vpc.yaml
    ├── subnets.yaml
    ├── internet-gateway.yaml
    ├── nat-gateway.yaml
    ├── route-tables.yaml
    ├── security-groups.yaml
    └── ec2.yaml

## Điều kiện tiên quyết
Trước khi chạy mã nguồn, đảm bảo máy trạm đã có sẵn:

1. **AWS CLI** đã được cài đặt và cấu hình thông tin xác thực.
2. Đã tạo sẵn **Key Pair** trên **AWS Console** (đúng Region) và tải file key pair về máy.
3. Đã cấu hình phân quyền bảo mật cho file key pair.

---

## Hướng dẫn triển khai

### Bước 1: Chuẩn bị tham số môi trường
Mở file **parameters.json**, cập nhật chính xác các giá trị sau:
1. **MyIp:** Địa chỉ IP Public mạng cộng thêm đuôi /32 (Ví dụ: 14.169.90.151/32).
2. **KeyName:** Tên Key Pair trên AWS (Ví dụ: nt548-keypair).

### Bước 2: Tạo kho chứa và Upload Template
Vì sử dụng Nested Stacks, CloudFormation yêu cầu các file template con phải được lưu trữ trên Amazon S3. Mở Terminal và chạy:

```bash
### Tạo một S3 bucket mới
aws s3 mb s3://nt548-cfn-templates-nhom03 --region ap-southeast-1

### Upload thư mục 'templates' lên S3
aws s3 cp templates/ s3://nt548-cfn-templates-nhom03/templates/ --recursive
```

### Bước 3: Triển khai Hạ tầng
Thực thi lệnh sau để AWS bắt đầu quá trình biên dịch và cấp phát tài nguyên:

```bash
aws cloudformation deploy \
  --template-file main.yaml \
  --stack-name nt548-lab01-nhom03 \
  --parameter-overrides file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ap-southeast-1
  ```

### (Chờ khoảng 3-5 phút đến khi Terminal báo Successfully created/updated stack).

### Bước 4: lấy các giá trị IP vừa được cấp phát bằng lệnh:

```bash
aws cloudformation describe-stacks --stack-name nt548-lab01-nhom03 --query 'Stacks[0].Outputs' --output table
```

## Xác minh hệ thống
Dự án tích hợp sẵn một kịch bản kiểm thử tự động gồm 12 bước để xác nhận tính toàn vẹn của kết nối mạng (Network Routing) và bảo mật (Security Groups).

### 1. Mở PowerShell bằng quyền Quản trị viên (nếu cần) tại thư mục cloudformation và chạy lệnh sau (thay thế đường dẫn Key và IP tương ứng):

```powershell
powershell -ExecutionPolicy Bypass -File ".\run-tests.ps1" -KeyPath "Đường_dẫn_tới_file.pem" -PublicIP <Public-IP> -PrivateIP <Private-IP>
```

### Hệ thống được chứng minh là hoạt động hoàn hảo khi toàn bộ 12 Test Cases (Bao gồm kiểm tra CLI và kiểm tra kết nối luồng mạng) đều báo [PASS].

## Dọn dẹp tài nguyên
Để tránh phát sinh chi phí AWS ngoài ý muốn, thu hồi toàn bộ hệ thống ngay sau khi hoàn thành:
Thực thi tuần tự các lệnh sau:

### 1. Xóa toàn bộ hạ tầng (Root stack sẽ tự động xóa các nested stacks)
aws cloudformation delete-stack --stack-name nt548-lab01-nhom03

### 2. Dọn rác trong S3 Bucket
aws s3 rm s3://nt548-cfn-templates-nhom03 --recursive

### 3. Đập bỏ S3 Bucket
aws s3 rb s3://nt548-cfn-templates-nhom03
