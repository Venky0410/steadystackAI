# steadystackAI
## Progress
### ✅ Phase 1 - Infrastructure
- [x] VPC created (eu-west-1)
- [x] Public Subnets (2)
- [x] Private Subnets (2)
- [x] Internet Gateway
- [x] NAT Gateway
- [x] Route Tables
- [x] EKS Cluster v1.31
- [x] Worker Nodes (t3.medium x2)
- [x] kubectl configured


### ✅ Phase 2 - Application
- [x] JewelHub microservices deployed
- [x] 6 services running on EKS
- [x] Docker images in ECR

### ✅ Phase 3 - Observability
- [x] Prometheus installed on EKS
- [x] Grafana installed on EKS
- [x] JewelHub Overview dashboard
- [x] Pod status monitoring
- [x] CPU + Memory tracking
- [x] Pod restart alerts

### ✅ Phase 4 - CI/CD
- [x] GitHub Actions pipeline
- [x] Auto Docker build on push
- [x] Auto push to AWS ECR
- [x] Auto deploy to EKS
- [x] Commit hash image tags
- [x] Deployment summary in GitHub
- [x] Rollback capability
- [x] Zero manual steps!

### ✅ Phase 5 - ELK Stack
- [x] Elasticsearch installed
- [x] Kibana installed
- [x] Filebeat installed as DaemonSet
- [x] JewelHub logs flowing
- [x] Kibana data view created
- [x] Log search working