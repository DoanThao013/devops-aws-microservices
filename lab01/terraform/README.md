# Lab 01 - Triển khai Hạ tầng AWS với Terraform (IaC)

Thư mục này chứa toàn bộ mã nguồn Terraform để tự động hóa việc cấp phát hạ tầng mạng cơ bản trên AWS. Kiến trúc được thiết kế tuân thủ các tiêu chuẩn bảo mật (phân tách Public/Private Subnet, sử dụng mô hình Bastion Host và NAT Gateway).

## Cấu trúc thư mục (Modular Architecture)

Dự án được phân chia thành các module độc lập để tăng tính tái sử dụng:

```text
terraform/
├── main.tf                  # Root file: Gọi và liên kết các module
├── variables.tf             # Khai báo các biến đầu vào tổng
├── outputs.tf               # Trả về các giá trị quan trọng (IP, ID) sau khi deploy
├── providers.tf             # Cấu hình AWS Provider
├── terraform.tfvars.example # File mẫu chứa tham số (Cần đổi tên thành .tfvars)
└── modules/                 # Thư mục chứa cấu hình chi tiết từng dịch vụ
    ├── vpc/
    ├── subnet/
    ├── internet_gateway/
    ├── nat_gateway/
    ├── route_table/
    ├── security_group/
    └── ec2/
```

## Điều kiện tiên quyết (Prerequisites)

Trước khi chạy mã nguồn, đảm bảo máy trạm (local machine) của bạn đã có sẵn:
1. **Terraform** (phiên bản `>= 1.5.0`).
2. **AWS CLI** đã được cài đặt và cấu hình thông tin xác thực (chạy lệnh `aws configure`).
3. Đã tạo sẵn **Key Pair** trên AWS Console (Region `ap-southeast-1`) và tải file `.pem` về máy (khuyến nghị đặt trong thư mục `~/.ssh/` hoặc `C:\Users\<Tên_User>\.ssh\`).

---

## Hướng dẫn triển khai (Deployment Guide)

### Bước 1: Chuẩn bị tham số môi trường
Sao chép file cấu hình mẫu để tạo file biến thực tế:
```bash
cp terraform.tfvars.example terraform.tfvars
```
*Mở file `terraform.tfvars` vừa tạo, cập nhật chính xác giá trị của `my_ip` (IP Public của máy bạn để giới hạn quyền SSH) và `key_name` (tên Key Pair trên AWS).*

### Bước 2: Khởi tạo và kiểm tra cú pháp
Mở Terminal/PowerShell tại thư mục `terraform` và thực thi:
```bash
terraform init       # Tải AWS Provider và khởi tạo workspace
terraform fmt        # Định dạng lại code cho chuẩn HCL
terraform validate   # Kiểm tra tính hợp lệ của mã nguồn
```

### Bước 3: Xem trước và Cấp phát tài nguyên
```bash
terraform plan       # Xem danh sách các tài nguyên chuẩn bị được tạo
terraform apply      # Tiến hành cấp phát (Gõ 'yes' để xác nhận)
```
*(Hoặc sử dụng `terraform apply -auto-approve` để bỏ qua bước gõ xác nhận).*

Sau khi hoàn tất, hệ thống sẽ in ra màn hình khối **Outputs** chứa các thông tin như `vpc_id`, `public_ec2_public_ip`, và `private_ec2_private_ip`.

---

## Xác minh hệ thống (Automated Testing)

Dự án tích hợp sẵn một kịch bản kiểm thử tự động để xác nhận tính toàn vẹn của kết nối mạng và Security Groups. Đợi khoảng 1-2 phút sau khi deploy để máy ảo khởi động, sau đó mở PowerShell và chạy lệnh sau:

```powershell
# Chuyển hướng đến thư mục chứa script test
cd ../tests/terraform/

# Chạy kịch bản (Thay thế IP bằng các giá trị thực tế lấy từ bước Outputs ở trên)
powershell -ExecutionPolicy Bypass -File ".\run-tests.ps1" -KeyName <tên-key> -PublicIP <Public-IP> -PrivateIP <Private-IP>
```
*Hệ thống hoạt động chính xác khi toàn bộ 7 Test Cases đều báo `[PASS]`.*

---

## Dọn dẹp tài nguyên (Cleanup)

Để tránh phát sinh chi phí AWS ngoài ý muốn (đặc biệt là chi phí duy trì Elastic IP và NAT Gateway), hãy thu hồi toàn bộ hệ thống ngay sau khi hoàn thành bài Lab:
```bash
terraform destroy -auto-approve
```