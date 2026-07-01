#!/bin/bash
# =====================
# Trigger Test Alert
# For Demo Purposes
# =====================

echo "🚨 Triggering JewelHub Alert..."

# Kill existing port forwards
pkill -f "port-forward" 2>/dev/null || true
sleep 3

# Port forward AI layer
kubectl port-forward \
  -n steadystackai \
  deployment/ai-layer 9090:8080 &

echo "⏳ Waiting for port forward..."
sleep 5

# Send test alert
curl -s -X POST \
  http://localhost:9090/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [{
      "status": "firing",
      "labels": {
        "alertname": "JewelHubHighErrorRate",
        "severity": "critical",
        "service": "frontend"
      },
      "annotations": {
        "summary": "JewelHub error rate too high!",
        "description": "More than 5% requests failing"
      }
    }]
  }'

echo ""
echo "✅ Alert sent! Watch logs with:"
echo "   ./watch-ai.sh"