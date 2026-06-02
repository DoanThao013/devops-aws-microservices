# Lab 02 — Câu 1: Tự động hóa Hạ tầng AWS với Terraform, GitHub Actions & Checkov

## Mục tiêu
Tự động hóa toàn trình (CI/CD) việc kiểm thử và triển khai hạ tầng AWS (VPC, EC2, NAT Gateway...) bằng GitHub Actions. Tích hợp quét bảo mật mã nguồn với Checkov và quản lý trạng thái hạ tầng (Remote State) an toàn qua Amazon S3.

## Các giai đoạn của Pipeline (Workflow Stages)
Luồng CI/CD được thiết kế bảo mật chặt chẽ qua 4 bước chính và 1 luồng dọn dẹp:

1. **Validate (Kiểm tra mã nguồn):** Tự động chạy `terraform fmt -check`, `terraform init -backend=false`, và `terraform validate` để đảm bảo code không có lỗi cú pháp.
2. **Security Scan (Quét bảo mật):** Sử dụng Checkov quét toàn bộ module Terraform để tìm lỗ hổng. Báo cáo định dạng SARIF được upload tự động lên tab **Security → Code scanning** của GitHub.
3. **Plan (Xem trước lộ trình):** Chỉ kích hoạt khi có Pull Request (PR). Tự động chạy `terraform plan` và comment kết quả trực tiếp vào PR để Reviewer đối chiếu.
4. **Apply (Triển khai thực tế):** Chỉ kích hoạt khi code được merge vào nhánh `main`. Tự động dùng `terraform apply -auto-approve` để khởi tạo hạ tầng trên AWS.
5. **Destroy (Dọn dẹp thủ công):** Một workflow riêng biệt (`destroy.yml`) cho phép kích hoạt bằng tay trên giao diện GitHub để thu hồi toàn bộ tài nguyên, tránh phát sinh chi phí.

## Yêu cầu cấu hình trước khi chạy

### 1. Tạo kho lưu trữ trạng thái (S3 Backend)
Để quy trình tự động hóa hoạt động trơn tru (đặc biệt là lệnh Destroy), hệ thống cần một nơi lưu trữ file "trí nhớ" `terraform.tfstate`.
- Đăng nhập AWS Console, tạo một S3 Bucket (Ví dụ: `nt548-terraform-state-23521551`) tại Region `ap-southeast-1`.
- Cập nhật tên Bucket này vào file `providers.tf`.

### 2. Thiết lập GitHub Secrets
Vào **Settings → Secrets and variables → Actions**, tạo 4 biến môi trường sau (Sử dụng tiền tố `CAU1_` để không xung đột với các câu khác trong cùng Repository):
- `CAU1_AWS_ACCESS_KEY_ID`: Khóa truy cập AWS (IAM User).
- `CAU1_AWS_SECRET_ACCESS_KEY`: Khóa bí mật AWS.
- `CAU1_MY_IP`: IP mạng cá nhân của bạn kèm Subnet Mask (VD: `42.117.146.92/32`) để cấu hình mở Port 22 (SSH).
- `CAU1_KEY_NAME`: Tên Key Pair đã tạo trên AWS (VD: `nt548-key`).

*(Hệ thống sử dụng cơ chế truyền Biến môi trường `TF_VAR_` siêu bảo mật, hoàn toàn không sử dụng file `.tfvars` tĩnh chứa dữ liệu nhạy cảm trên Repo).*

## Tham chiếu Checkov (Bảo mật cấu hình)
Pipeline đã được tinh chỉnh để bỏ qua (skip) một số quy tắc không bắt buộc cho môi trường Lab sinh viên:
- `CKV_AWS_8`: Yêu cầu mã hóa ổ cứng EBS.
- `CKV_AWS_135`: Yêu cầu tối ưu hóa ổ cứng EBS.
- `CKV_AWS_24` & `CKV_AWS_25`: Các quy tắc bảo mật nhóm (Security Group) nghiêm ngặt hơn.

## Hướng dẫn dọn dẹp hệ thống (Cleanup)
Sau khi báo cáo bài Lab hoàn tất, truy cập tab **Actions** trên GitHub:
1. Chọn Workflow **Destroy Infrastructure (Cau 1)**.
2. Bấm nút **Run workflow** để hệ thống tự động xóa toàn bộ VPC, EC2, NAT Gateway.
3. Sau khi Destroy thành công, lên giao diện AWS Console xóa S3 Bucket (Empty & Delete) để tài khoản AWS trở về trạng thái nguyên bản 100%.