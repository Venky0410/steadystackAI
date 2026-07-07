# steadystackAI
## 📊 Progress
### ✅ Phase 1 — Infrastructure
- [x] VPC created (eu-west-1)
- [x] Public Subnets (2)
- [x] Private Subnets (2)
- [x] Internet Gateway
- [x] NAT Gateway
- [x] Route Tables
- [x] EKS Cluster v1.31
- [x] Worker Nodes (t3.medium x2)
- [x] kubectl configured
- [x] Terraform S3 backend state

### ✅ Phase 2 — Application
- [x] JewelHub microservices deployed
- [x] 6 services running on EKS
- [x] Docker images in ECR
- [x] Health checks configured
- [x] Resource limits defined

### ✅ Phase 3 — Observability
- [x] Prometheus installed on EKS
- [x] Grafana installed on EKS
- [x] JewelHub Overview dashboard
- [x] Pod status monitoring
- [x] CPU + Memory tracking
- [x] Pod restart alerts
- [x] Custom alert rules
- [x] Grafana exposed via LoadBalancer

### ✅ Phase 4 — CI/CD
- [x] GitHub Actions pipeline
- [x] Auto Docker build on push
- [x] Auto push to AWS ECR
- [x] Auto deploy to EKS
- [x] Commit hash image tags
- [x] Deployment summary in GitHub
- [x] Rollback capability
- [x] Zero manual steps!
- [x] One click setup workflow
- [x] One click destroy workflow
- [x] Resumable workflow options
  - setup-monitoring
  - setup-elk
  - setup-jewelhub
- [x] Skip build if no code changes
- [x] Condition-based health checks

### ✅ Phase 5 — ELK Stack
- [x] Elasticsearch 7.17.3 installed
- [x] Kibana 7.17.3 installed
- [x] Filebeat 7.17.3 as DaemonSet
- [x] JewelHub logs flowing
- [x] Kibana data view created
- [x] Log search working
- [x] Fixed OOMKilled (2Gi memory)
- [x] Fixed Kibana pre-install hooks
- [x] ELK images cached in ECR
- [x] Version pinned to 7.17.3

### ✅ Phase 6 — SLOs + Error Budgets
- [x] Availability SLI defined
- [x] Latency SLI defined
- [x] Error rate SLI defined
- [x] 99.9% availability SLO target
- [x] 200ms latency SLO target
- [x] Error budget tracking (43 mins/month)
- [x] Burn rate calculations
- [x] Multi-window burn rate alerts
  - Fast burn (14x) → Critical
  - Slow burn (6x) → Warning
  - Budget < 25% → Warning
  - Budget < 10% → Critical
- [x] Grafana SLO dashboard
  - Availability gauge
  - Error budget gauge
  - Burn rate gauge
  - Latency percentiles (P50/P95/P99)
  - Budget consumed tracking
- [x] prometheus_flask_exporter added
- [x] ServiceMonitor configured
- [x] Prometheus scraping JewelHub
- [x] SLO data verified in Grafana


### ✅ Phase 7 — AI Layer
- [x] Claude API integration
- [x] Alert webhook receiver
- [x] Prometheus metrics collection
- [x] Elasticsearch log querying
- [x] Incident analysis with Claude
- [x] Automated postmortem generation
- [x] Deployed on EKS
- [x] Connected to Alertmanager
- [x] MTTR reduced from hours to minutes


### ✅ Phase 8 — Chaos Engineering
- [x] Chaos experiment script created
- [x] cart-service pod killed deliberately
- [x] Kubernetes auto-healed in ~30 secs
- [x] SLOs reacted in Grafana
- [x] Burn rate spiked during chaos
- [x] AI Layer detected incident
- [x] Claude analyzed real errors
- [x] Postmortem auto-generated
- [x] System fully recovered
- [x] Zero manual intervention
- [x] Proven end-to-end pipeline!