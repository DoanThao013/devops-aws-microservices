# Lab 02 — Câu 2: CloudFormation + AWS CodePipeline + cfn-lint + Taskcat

## Mục tiêu
Triển khai pipeline CI/CD cho hạ tầng CloudFormation Lab 01, dùng:
- **AWS CodeCommit** làm source
- **AWS CodeBuild** chạy `cfn-lint` + `taskcat`
- **AWS CodePipeline** điều phối: Source → Build → Deploy (ChangeSet → Approval → Execute)

## Cấu trúc
```
cau2-cloudformation-codepipeline/
├── pipeline.yaml          # CFN tự deploy pipeline + CodeBuild + IAM roles
├── buildspec.yml          # CodeBuild lint + validate + taskcat
├── .taskcat.yml           # Cấu hình Taskcat (test region, parameters)
└── README.md
```

## Cách chạy

### 1. Push code lên CodeCommit
```bash
aws codecommit create-repository --repository-name devops-aws-microservices --region ap-southeast-1
git remote add codecommit codecommit::ap-southeast-1://devops-aws-microservices
git push codecommit main
```

### 2. Deploy pipeline stack
```bash
aws cloudformation deploy \
  --template-file pipeline.yaml \
  --stack-name nt548-cfn-pipeline-stack \
  --parameter-overrides \
      ArtifactBucketName=nt548-cfn-pipeline-artifacts-<groupID> \
      RepoName=devops-aws-microservices \
      BranchName=main \
  --capabilities CAPABILITY_NAMED_IAM \
  --region ap-southeast-1
```

### 3. Theo dõi pipeline
- Console: https://console.aws.amazon.com/codesuite/codepipeline
- Mỗi commit lên branch `main` sẽ trigger: lint → taskcat test → ChangeSet → manual approval → execute

## Kiểm thử local
```bash
cd lab02/cau2-cloudformation-codepipeline
cfn-lint ../../lab01/cloudformation/main.yaml ../../lab01/cloudformation/templates/*.yaml
taskcat test run -t lab01-test
```

## Người phụ trách
**TV4 — Lab 02 Câu 2 Lead**
