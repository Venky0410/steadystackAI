#!/bin/bash
# =====================
# Watch AI Layer Logs
# For Demo Purposes
# =====================

echo "👀 Watching AI Layer..."
echo "================================"
echo "You will see:"
echo "→ Alert received"
echo "→ Metrics collected"
echo "→ Logs searched"
echo "→ Claude analyzing..."
echo "→ Postmortem saved!"
echo "================================"
echo ""

kubectl logs -f \
  -n steadystackai \
  -l app=ai-layer