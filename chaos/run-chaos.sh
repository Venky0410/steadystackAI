#!/bin/bash
# =====================
# JewelHub Chaos Test
# Kill cart-service pod
# =====================

echo "🔥 Starting Chaos Experiment!"
echo "Target: cart-service pod"
echo "================================"

# Step 1 - Show current state
echo ""
echo "📊 BEFORE CHAOS:"
kubectl get pods -n jewelhub
echo ""

# Step 2 - Start watching logs
echo "👀 Starting AI Layer watch..."
kubectl logs -f \
  -n steadystackai \
  -l app=ai-layer &
AI_LOG_PID=$!

# Step 3 - Kill cart-service pod
echo ""
echo "💥 Killing cart-service pod..."
kubectl delete pod \
  -n jewelhub \
  -l app=cart-service \
  --force

echo "✅ Pod deleted!"
echo ""

# Step 4 - Watch recovery
echo "⏳ Watching recovery..."
sleep 5
kubectl get pods -n jewelhub --watch &
WATCH_PID=$!

# Step 5 - Generate traffic during chaos
echo ""
echo "🌊 Generating traffic during chaos..."
JEWELHUB=$(kubectl get svc frontend \
  -n jewelhub \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

for i in {1..30}; do
  curl -s http://$JEWELHUB/products > /dev/null
  curl -s http://$JEWELHUB/cart > /dev/null
  echo "Request $i sent"
  sleep 2
done

# Step 6 - Show after state
echo ""
echo "📊 AFTER CHAOS:"
kubectl get pods -n jewelhub

# Step 7 - Trigger AI analysis
echo ""
echo "🤖 Triggering AI Analysis..."
pkill -f "port-forward" 2>/dev/null || true
sleep 3

kubectl port-forward \
  -n steadystackai \
  deployment/ai-layer 9090:8080 &
sleep 5

curl -s -X POST \
  http://localhost:9090/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [{
      "status": "firing",
      "labels": {
        "alertname": "JewelHubCartServiceDown",
        "severity": "critical",
        "service": "cart-service"
      },
      "annotations": {
        "summary": "Cart service pod killed by chaos!",
        "description": "Chaos experiment: pod deleted"
      }
    }]
  }'

echo ""
echo "================================"
echo "✅ Chaos experiment complete!"
echo "Check Grafana for SLO impact"
echo "Check Kibana for postmortem"
echo "================================"

# Cleanup background processes
kill $WATCH_PID 2>/dev/null || true
kill $AI_LOG_PID 2>/dev/null || true