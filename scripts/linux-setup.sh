#!/bin/bash
# =============================================================
# Linux Administration & User Management Setup Script
# DevOps CI/CD Security Platform
# =============================================================

set -e

LOG_FILE="/tmp/linux-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "============================================"
echo " DevOps Platform - Linux Setup"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"

# ----------------------------------------------------------
# TASK 1: Create project directory structure
# ----------------------------------------------------------
echo "[1] Creating project directory structure..."
PROJECT_DIR="/opt/company-devops-platform"
mkdir -p "$PROJECT_DIR"/{configs,deployments,policies,reports/sonarqube,artifacts,backup}
echo "  Directory structure created at $PROJECT_DIR"

# ----------------------------------------------------------
# TASK 2: Create configuration files
# ----------------------------------------------------------
echo "[2] Creating configuration files..."
cat > "$PROJECT_DIR/configs/deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-app
  template:
    metadata:
      labels:
        app: devops-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
      containers:
      - name: devops-app
        image: devops-app:1.0.0
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
          readOnlyRootFilesystem: true
EOF

cat > "$PROJECT_DIR/configs/pipeline.yaml" << 'EOF'
pipeline:
  name: devops-cicd-pipeline
  stages:
    - checkout
    - build
    - test
    - security_scan
    - deploy
  triggers:
    - branch: development
      event: push
    - branch: production
      event: push
EOF

cat > "$PROJECT_DIR/configs/security.conf" << 'EOF'
# Security Configuration
ALLOW_ROOT_EXEC=false
ENFORCE_IMAGE_TAGS=true
PRIVILEGED_CONTAINERS=false
SECURITY_SCAN_ENABLED=true
QUALITY_GATE_ENFORCE=true
OPA_POLICY_ENFORCE=true
EOF

echo "  Configuration files created."

# ----------------------------------------------------------
# TASK 3: Create users
# ----------------------------------------------------------
echo "[3] Creating users..."
for USER in developer tester devopsadmin; do
  if ! id "$USER" &>/dev/null; then
    sudo useradd -m -s /bin/bash "$USER"
    echo "  Created user: $USER"
  else
    echo "  User already exists: $USER"
  fi
done

# ----------------------------------------------------------
# TASK 4: Create groups
# ----------------------------------------------------------
echo "[4] Creating groups..."
for GROUP in developers operations; do
  if ! getent group "$GROUP" &>/dev/null; then
    sudo groupadd "$GROUP"
    echo "  Created group: $GROUP"
  else
    echo "  Group already exists: $GROUP"
  fi
done

# ----------------------------------------------------------
# TASK 5: Add users to groups
# ----------------------------------------------------------
echo "[5] Adding users to groups..."
sudo usermod -aG developers developer
sudo usermod -aG developers tester
sudo usermod -aG operations devopsadmin
echo "  developer, tester → developers group"
echo "  devopsadmin → operations group"

# ----------------------------------------------------------
# TASK 6: Assign permissions
# ----------------------------------------------------------
echo "[6] Assigning permissions..."
sudo chown -R root:developers "$PROJECT_DIR"
sudo chmod -R 775 "$PROJECT_DIR"                   # read/write for developers group
sudo chown devopsadmin:operations "$PROJECT_DIR"    # admin ownership
sudo chmod 2775 "$PROJECT_DIR"                      # setgid for group inheritance
echo "  Permissions assigned."

# ----------------------------------------------------------
# TASK 7: Backup config files with timestamps
# ----------------------------------------------------------
echo "[7] Backing up configuration files with timestamps..."
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
for FILE in "$PROJECT_DIR"/configs/*; do
  BASENAME=$(basename "$FILE")
  BACKUP_NAME="${BASENAME%.*}_${TIMESTAMP}.${BASENAME##*.}"
  cp "$FILE" "$PROJECT_DIR/backup/$BACKUP_NAME"
  echo "  Backed up: $BACKUP_NAME"
done

# ----------------------------------------------------------
# TASK 8: Display complete project structure
# ----------------------------------------------------------
echo "[8] Project structure:"
find "$PROJECT_DIR" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'

# ----------------------------------------------------------
# TASK 9: Create background process and terminate it
# ----------------------------------------------------------
echo "[9] Background process management..."
sleep 300 &
BG_PID=$!
echo "  Started background process PID: $BG_PID"
ps -ef | grep "sleep 300" | grep -v grep
kill "$BG_PID"
echo "  Terminated background process PID: $BG_PID"

# ----------------------------------------------------------
# TASK 10: Display running processes with parent-child
# ----------------------------------------------------------
echo "[10] Running processes (parent-child relationships):"
ps -ejH | head -40
echo "  PID → PPID relationships shown above."

# ----------------------------------------------------------
# TASK 11: Create compressed archive
# ----------------------------------------------------------
echo "[11] Creating compressed archive..."
ARCHIVE_NAME="company-devops-platform_${TIMESTAMP}.tar.gz"
tar -czf "/tmp/$ARCHIVE_NAME" -C /opt company-devops-platform
echo "  Archive created: /tmp/$ARCHIVE_NAME"
ls -lh "/tmp/$ARCHIVE_NAME"

echo "============================================"
echo " Linux setup completed successfully!"
echo "============================================"
