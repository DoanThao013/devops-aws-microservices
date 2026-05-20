# Lab 02 — Câu 3: Microservices + Jenkins + Docker + Kubernetes + SonarQube + Trivy

## Mục tiêu
Xây dựng pipeline CI/CD đầy đủ cho hệ microservices 2 service (Node.js + Python):
- **Build & Test**: npm/pytest
- **Code Quality**: SonarQube + Quality Gate
- **Build Image**: Docker multi-stage
- **Security Scan**: Trivy (fail nếu có HIGH/CRITICAL)
- **Deploy**: Kubernetes (minikube/EKS) qua `kubectl`

## Cấu trúc
```
cau3-microservices-jenkins-k8s/
├── service-a/                  # Node.js + Express
│   ├── Dockerfile, package.json
│   ├── src/index.js
│   └── test/index.test.js
├── service-b/                  # Python + Flask
│   ├── Dockerfile, requirements.txt
│   ├── app.py
│   └── test_app.py
├── k8s/                        # Kubernetes manifests
│   ├── 00-namespace.yaml
│   ├── 10-service-a.yaml       # Deployment + NodePort
│   ├── 20-service-b.yaml       # Deployment + ClusterIP
│   └── 30-ingress.yaml
├── jenkins/docker-compose.jenkins.yml
├── sonar/sonar-project.properties
├── docker-compose.yml          # Local dev: services + sonarqube
└── Jenkinsfile                 # Declarative pipeline 8 stages
```

## Pipeline stages (Jenkinsfile)
1. Checkout
2. Unit Tests (parallel: service-a, service-b)
3. SonarQube Analysis
4. Quality Gate (abort nếu fail)
5. Build Docker Images (parallel)
6. Trivy Image Scan (fail HIGH/CRITICAL)
7. Push Images (registry)
8. Deploy to Kubernetes (chỉ branch `main`)

## Quickstart local

```bash
# 1. Khởi động SonarQube + 2 services
cd lab02/cau3-microservices-jenkins-k8s
docker compose up -d --build
# → service-a: http://localhost:3000
# → service-b: http://localhost:5000
# → sonarqube: http://localhost:9000  (admin/admin)

# 2. Test cross-service
curl http://localhost:3000/aggregate

# 3. Khởi động Jenkins
docker compose -f jenkins/docker-compose.jenkins.yml up -d
# → http://localhost:8080
```

## Yêu cầu Jenkins credentials
| ID | Type | Dùng cho |
|----|------|----------|
| `registry-creds` | Username/password | docker login |
| `kubeconfig` | Secret file | kubectl deploy |
| `sonar-token` | Secret text | SonarQube auth |

## Trivy local check
```bash
trivy image nt548/service-a:dev
trivy image nt548/service-b:dev
```

## K8s deploy thủ công
```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/10-service-a.yaml
kubectl apply -f k8s/20-service-b.yaml
kubectl apply -f k8s/30-ingress.yaml
kubectl -n nt548 get pods,svc,ingress
```

## Người phụ trách
**TV5 — Lab 02 Câu 3 Lead** (microservices + Jenkins)
**TV1 — Hỗ trợ K8s + SonarQube + Trivy**
