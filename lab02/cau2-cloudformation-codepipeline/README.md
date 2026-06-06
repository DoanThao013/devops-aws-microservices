# Lab 02 — Câu 2: Tự động hóa Hạ tầng AWS với CloudFormation, CodePipeline & Taskcat

## Mục tiêu
Tự động hóa toàn trình (CI/CD) việc kiểm thử và triển khai hạ tầng AWS (VPC, EC2, NAT Gateway...) thông qua dịch vụ AWS CodePipeline. Tích hợp kiểm tra lỗi cú pháp với `cfn-lint`, kiểm thử giả lập triển khai thực tế bằng `taskcat` và quản lý kiến trúc mẫu (Nested Stacks) tập trung trên Amazon S3.

## Các giai đoạn của Pipeline (Workflow Stages)
Luồng CI/CD được thiết kế theo chuẩn AWS DevOps với 3 bước chính tự động và 1 luồng dọn dẹp riêng biệt:

1. **Source (Lấy mã nguồn):** Tự động kích hoạt (trigger) khi có thay đổi được đẩy lên kho lưu trữ mã nguồn (CodeCommit/GitHub), lấy bản code mới nhất đưa vào luồng CI/CD.
2. **Lint And Validate (Kiểm thử & Đánh giá):** AWS CodeBuild tự động chạy `cfn-lint` để rà soát lỗi cú pháp của các file YAML. Sau đó kích hoạt `taskcat` để giả lập triển khai thử nghiệm toàn bộ hệ thống lên môi trường đám mây độc lập, đảm bảo hạ tầng không có lỗi logic trước khi cấp phép đi tiếp.
3. **Deploy To Dev (Triển khai thực tế):** Thực hiện qua 3 pha kiểm soát chặt chẽ:
   - **CreateChangeSet:** Tạo bản nháp (Change Set) đối chiếu những thay đổi sẽ diễn ra trên AWS so với hạ tầng cũ.
   - **ManualApproval:** Luồng tự động tạm dừng, chờ người quản trị (QA/DevOps) xem xét và bấm "Approve" (Phê duyệt) trực tiếp trên giao diện AWS CodePipeline.
   - **ExecuteChangeSet:** Chính thức triển khai (Apply) hạ tầng thật (VPC, EC2...) dựa trên Change Set đã duyệt.
4. **Destroy (Dọn dẹp thủ công):** Kịch bản thu hồi tài nguyên (`buildspec-destroy.yml`) được tách riêng biệt, thực thi qua AWS CLI nhằm tránh rủi ro hệ thống CI/CD tự động kích hoạt mìn phá sập môi trường.

## Yêu cầu cấu hình trước khi chạy

### 1. Tạo kho lưu trữ Template (S3 Bootstrapping)
Do hệ thống sử dụng kiến trúc Nested Stacks (Template lồng nhau), CloudFormation yêu cầu các file template con (`vpc.yaml`, `ec2.yaml`...) phải tồn tại sẵn trên S3 trước khi triển khai file `main.yaml`.
- Tạo một S3 Bucket trung tâm (Ví dụ: `nt548-cfn-templates-nhom03`) tại Region `ap-southeast-1`.
- Sử dụng lệnh `aws s3 sync` đẩy thư mục `templates/` lên Bucket này. Đảm bảo tên Bucket khớp với biến truyền vào lúc triển khai.

### 2. Thiết lập thông số Pipeline (Parameter Overrides)
Tại bước **DeployToDev (CreateChangeSet)** trong CodePipeline, cần cấu hình các thông số ghi đè (Parameter overrides) để cấp thông tin cho CloudFormation xây dựng hạ tầng:
- `MyIp`: IP mạng cá nhân (hoặc Any IPv4 `0.0.0.0/0`) kèm Subnet Mask để giới hạn quyền truy cập SSH (Port 22) vào Public EC2 tại Security Group.
- `KeyName`: Tên Key Pair đã khởi tạo và lưu trữ an toàn trên máy cục bộ (VD: `nt548-keypair.pem`).
- `TemplateBucket`: Tên S3 Bucket đã tạo ở phần Bootstrapping (VD: `nt548-cfn-templates-nhom03`).
- `AvailabilityZone`: Vùng sẵn sàng ưu tiên để triển khai mạng con (VD: `ap-southeast-1a`).

## Tinh chỉnh Taskcat & Quyền hạn (IAM Roles)
Do đặc thù của môi trường Lab áp dụng Nested Stacks và sự quản lý quyền hạn gắt gao của hệ thống AWS IAM, cấu hình đã được tinh chỉnh để giải quyết các nút thắt bảo mật:

- **Vượt qua giới hạn đường dẫn của Taskcat:** Mặc định Taskcat sẽ zip code và đẩy lên một S3 Bucket ngẫu nhiên, làm gãy đường dẫn tuyệt đối được thiết lập trong `main.yaml`. Đã xử lý bằng cách trỏ cố định biến môi trường để Taskcat sử dụng trực tiếp S3 Bucket thật (`nt548-cfn-templates-nhom03`) giúp pass bài test giả lập.
- **Bổ sung quyền `iam:PassRole`:** Cấp quyền cho `CodeBuildRole` để nó có thể AssumeRole và giao phó (PassRole) quyền hạn cho CloudFormation khi khởi tạo các Stack con (VpcStack, Ec2Stack).
- **Cập nhật Trust Relationship:** Mở rộng chính sách tin cậy (Trust Policy), cho phép cả `codebuild.amazonaws.com` và `cloudformation.amazonaws.com` được quyền sử dụng Role để luân chuyển công việc xuyên suốt luồng Pipeline.

## Hướng dẫn dọn dẹp hệ thống (Cleanup)
Vì cấu trúc của AWS CodePipeline ưu tiên phân phối liên tục và không hỗ trợ kích hoạt thủ công (workflow_dispatch) như GitHub Actions, bắt buộc phải dọn dẹp qua AWS CLI để tránh bỏ sót tài nguyên rác và phát sinh chi phí ngầm:
1. Mở Terminal/PowerShell đã cấu hình chứng chỉ AWS CLI.
2. Chạy lệnh xóa toàn bộ hạ tầng (CloudFormation sẽ tự động tính toán dependency tree để thu hồi tài nguyên theo đúng trình tự ngọn xuống gốc):
   ```bash
   aws cloudformation delete-stack --stack-name nt548-lab01-dev --region ap-southeast-1