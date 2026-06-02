# Lab 02 — Câu 1: Tự động hóa Hạ tầng AWS với Terraform, GitHub Actions & Checkov

## Mục tiêu
Tự động hóa toàn trình (CI/CD) việc kiểm thử và triển khai hạ tầng AWS (VPC, EC2, NAT Gateway...) bằng GitHub Actions. Tích hợp quét bảo mật mã nguồn với Checkov và quản lý trạng thái hạ tầng (Remote State) an toàn qua Amazon S3.

## Các giai đoạn của Pipeline (Workflow Stages)
Luồng CI/CD được thiết kế theo chuẩn DevOps với 4 bước chính và 1 luồng dọn dẹp riêng biệt:

1. **Validate (Kiểm tra mã nguồn):** Tự động chạy `terraform fmt -check`, `terraform init -backend=false`, và `terraform validate` để đảm bảo code sạch và không có lỗi cú pháp.
2. **Security Scan (Quét bảo mật):** Sử dụng Checkov quét toàn bộ module Terraform. Báo cáo định dạng SARIF được tự động đẩy lên tab **Security → Code scanning** của GitHub.
3. **Plan (Xem trước lộ trình):** Chỉ kích hoạt khi có Pull Request (PR) hoặc chạy thủ công. Tự động chạy `terraform plan` và comment kết quả trực tiếp vào PR để Reviewer đối chiếu.
4. **Apply (Triển khai thực tế):** Chỉ kích hoạt khi code được merge/push vào nhánh `main` hoặc chạy thủ công. Tự động dùng `terraform apply -auto-approve` để khởi tạo hạ tầng trên AWS.
5. **Destroy (Dọn dẹp thủ công):** Một workflow `destroy.yml` riêng biệt cho phép thu hồi toàn bộ tài nguyên bằng 1 click trên giao diện GitHub, tránh phát sinh chi phí.

## Yêu cầu cấu hình trước khi chạy

### 1. Tạo kho lưu trữ trạng thái (S3 Backend)
Hệ thống cần một nơi lưu trữ file "trí nhớ" `terraform.tfstate` để phục vụ cho việc cập nhật và dọn dẹp hạ tầng tự động.
- Tạo một S3 Bucket (Ví dụ: `nt548-terraform-state-23521551`) tại Region `ap-southeast-1`.
- Đảm bảo tên Bucket khớp với cấu hình trong khối `backend "s3"` của file `providers.tf`.

### 2. Thiết lập GitHub Secrets
Truy cập **Settings → Secrets and variables → Actions**, tạo 4 biến môi trường (Sử dụng tiền tố `CAU1_` để cách ly với các câu khác trong Monorepo):
- `CAU1_AWS_ACCESS_KEY_ID`: Khóa truy cập AWS IAM.
- `CAU1_AWS_SECRET_ACCESS_KEY`: Khóa bí mật AWS IAM.
- `CAU1_MY_IP`: IP mạng cá nhân kèm Subnet Mask (VD: `14.232.145.22/32`) để giới hạn quyền truy cập SSH (Port 22) vào Public EC2.
- `CAU1_KEY_NAME`: Tên Key Pair đã tồn tại trên AWS (VD: `nt548-key`).

*(Lưu ý: Môi trường sử dụng EC2 `t3.micro` để tuân thủ chuẩn Free Tier mới nhất của AWS tại region ap-southeast-1).*

## Tinh chỉnh Checkov (Security Scanning)
Do tính chất của một môi trường Lab sinh viên (ưu tiên tối ưu chi phí và bám sát yêu cầu đề bài), cấu hình Checkov đã được tinh chỉnh để bỏ qua (skip) các quy tắc Enterprise sau đây:

- **`CKV_AWS_88`**: Yêu cầu EC2 không được có Public IP. (Bỏ qua vì đề bài Lab bắt buộc phải tạo Public EC2 để truy cập từ Internet).
- **`CKV_AWS_8`**: Yêu cầu mã hóa ổ cứng EBS. (Bỏ qua vì không bắt buộc và giảm thiểu độ phức tạp cấu hình KMS Key cho bài Lab).
- **`CKV_AWS_135`**: Yêu cầu bật tính năng EBS Optimized. (Bỏ qua vì các dòng máy Free Tier như `t3.micro` mặc định có hoặc không cần thiết).
- **`CKV2_AWS_11`**: Yêu cầu bật VPC Flow Logs. (Bỏ qua vì tính năng ghi log mạng sẽ làm phát sinh chi phí lưu trữ trên S3/CloudWatch).
- **`CKV2_AWS_41`**: Yêu cầu gắn IAM Role cho mọi EC2. (Bỏ qua vì kiến trúc hiện tại EC2 chưa cần gọi API nào của AWS từ bên trong OS).
- **`CKV2_AWS_5`**: Yêu cầu Security Group phải được đính kèm. (Bỏ qua do đây là một false-positive của Checkov khi nhận diện liên kết Module Terraform).

## Hướng dẫn dọn dẹp hệ thống (Cleanup)
Sau khi kiểm tra hạ tầng hoàn tất, bắt buộc phải dọn dẹp để không tốn tiền:
1. Truy cập tab **Actions** trên GitHub.
2. Chọn Workflow **Destroy Infrastructure - Lab 02 Cau 1**.
3. Bấm **Run workflow** để Terraform tự động xóa toàn bộ VPC, EC2, NAT Gateway.
4. (Tùy chọn) Lên giao diện AWS Console xóa S3 Bucket chứa file state để dọn sạch 100%.