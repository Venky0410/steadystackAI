#!/bin/bash

echo "🔍 Fetching all SteadyStackAI URLs..."
echo "======================================="

# Connect to EKS
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name steadystackai-cluster \
  --quiet

echo ""
echo "💍 JewelHub:"
JEWELHUB=$(kubectl get svc frontend \
  -n jewelhub \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
  2>/dev/null)
if [ -z "$JEWELHUB" ]; then
  echo "   ❌ Not deployed yet"
else
  echo "   http://$JEWELHUB"
fi

echo ""
echo "📊 Grafana:"
GRAFANA=$(kubectl get svc prometheus-grafana \
  -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
  2>/dev/null)
if [ -z "$GRAFANA" ]; then
  echo "   ❌ Not deployed yet"
else
  echo "   http://$GRAFANA"
  echo "   Login: admin / JewelHub@2025"
fi

echo ""
echo "📈 Prometheus:"
PROMETHEUS=$(kubectl get svc prometheus-kube-prometheus-prometheus \
  -n monitoring \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
  2>/dev/null)
if [ -z "$PROMETHEUS" ]; then
  echo "   ❌ Not exposed yet"
else
  echo "   http://$PROMETHEUS:9090"
fi

echo ""
echo "📋 Kibana:"
KIBANA=$(kubectl get svc kibana-kibana \
  -n logging \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
  2>/dev/null)
if [ -z "$KIBANA" ]; then
  echo "   ❌ Not deployed yet"
else
  echo "   http://$KIBANA:5601"
  # Get Kibana password
  KIBANA_PASS=$(kubectl get secret \
    elasticsearch-master-credentials \
    -n logging \
    -o jsonpath='{.data.password}' \
    2>/dev/null | base64 --decode)
  echo "   Login: elastic / $KIBANA_PASS"
fi

echo ""
echo "======================================="
echo "✅ Done!"