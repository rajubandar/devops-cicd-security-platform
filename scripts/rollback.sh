#!/bin/bash
# =============================================================
# Rollback Script - Failed Deployment Recovery
# =============================================================

set -e

DEPLOYMENT_NAME="${1:-devops-app}"
NAMESPACE="${2:-default}"

echo "[ROLLBACK] Starting rollback for deployment: $DEPLOYMENT_NAME"
echo "[ROLLBACK] Namespace: $NAMESPACE"
echo "[ROLLBACK] Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

# Check if kubectl is available (Kubernetes rollback)
if command -v kubectl &>/dev/null; then
  echo "[ROLLBACK] Rolling back Kubernetes deployment..."
  kubectl rollout undo deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE"
  kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=120s
  echo "[ROLLBACK] Kubernetes rollback completed."
else
  echo "[ROLLBACK] kubectl not found. Using Docker rollback..."
  PREV_IMAGE=$(cat artifacts/previous-image.txt 2>/dev/null || echo "devops-app:latest")
  docker pull "$PREV_IMAGE"
  docker stop devops-app-container || true
  docker run -d --name devops-app-container -p 8080:8080 "$PREV_IMAGE"
  echo "[ROLLBACK] Docker rollback to image $PREV_IMAGE completed."
fi

# Generate rollback report
REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"
cat > "$REPORT_DIR/rollback-report.json" << EOF
{
  "rollback_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "deployment": "$DEPLOYMENT_NAME",
  "namespace": "$NAMESPACE",
  "status": "completed",
  "trigger": "automated_failure_recovery"
}
EOF

echo "[ROLLBACK] Report saved to $REPORT_DIR/rollback-report.json"
echo "[ROLLBACK] Rollback finished successfully."
