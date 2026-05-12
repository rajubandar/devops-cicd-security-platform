#!/bin/bash
# =============================================================================
# Linux Administration & User Management Setup Script
# DevOps CI/CD Security Platform
# =============================================================================

set -e

echo "========================================="
echo " DevOps Platform - Linux Setup Script"
echo "========================================="

# -----------------------------------------------------------------------------
# SECTION 1: Create Project Directory Structure
# -----------------------------------------------------------------------------
echo "[1/6] Creating project directory structure..."

PROJECT_DIR="/opt/company-devops-platform"

mkdir -p "$PROJECT_DIR/configs"
mkdir -p "$PROJECT_DIR/deployments"
mkdir -p "$PROJECT_DIR/policies"
mkdir -p "$PROJECT_DIR/reports"
mkdir -p "$PROJECT_DIR/artifacts"
mkdir -p "$PROJECT_DIR/backup"

echo "  [OK] Project directories created at $PROJECT_DIR"

# -----------------------------------------------------------------------------
# SECTION 2: Create Configuration Files
# -----------------------------------------------------------------------------
echo "[2/6] Creating configuration files..."

# deployment.yaml
cat > "$PROJECT_DIR/configs/deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-app
  namespace: production
spec:
  replicas: 3
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
          image: myregistry/devops-app:v1.2.3
          securityContext:
            privileged: false
            allowPrivilegeEscalation: false
          ports:
            - containerPort: 8080
          resources:
            limits:
              memory: "256Mi"
              cpu: "500m"
EOF

# pipeline.yaml
cat > "$PROJECT_DIR/configs/pipeline.yaml" << 'EOF'
pipeline:
  name: devops-cicd-pipeline
  version: "1.0"
  triggers:
    - push:
        branches:
          - development
  stages:
    - name: checkout
      steps:
        - uses: actions/checkout@v4
    - name: build
      steps:
        - run: echo "Building application..."
    - name: test
      steps:
        - run: echo "Running tests..."
    - name: security
      steps:
        - run: conftest test deployments/ --policy policies/
    - name: deploy
      steps:
        - run: echo "Deploying application..."
EOF

# security.conf
cat > "$PROJECT_DIR/configs/security.conf" << 'EOF'
# Security Configuration File
# DevOps CI/CD Security Platform

[general]
allow_root_execution=false
require_image_tags=true
allow_privileged_containers=false
minimum_replicas=2

[network]
allow_host_network=false
allow_host_pid=false
allow_host_ipc=false

[secrets]
scan_for_secrets=true
fail_on_secret_detection=true

[compliance]
enforce_opa_policies=true
sonarqube_quality_gate=true
EOF

echo "  [OK] Configuration files created"

# -----------------------------------------------------------------------------
# SECTION 3: Create Users and Groups
# -----------------------------------------------------------------------------
echo "[3/6] Creating users and groups..."

# Create groups
groupadd -f developers
groupadd -f operations
echo "  [OK] Groups created: developers, operations"

# Create users (with home directories)
useradd -m -s /bin/bash developer  2>/dev/null || echo "  [INFO] User 'developer' already exists"
useradd -m -s /bin/bash tester     2>/dev/null || echo "  [INFO] User 'tester' already exists"
useradd -m -s /bin/bash devopsadmin 2>/dev/null || echo "  [INFO] User 'devopsadmin' already exists"
echo "  [OK] Users created: developer, tester, devopsadmin"

# Add users to groups
usermod -aG developers developer
usermod -aG developers tester
usermod -aG operations devopsadmin
echo "  [OK] Users added to groups"

# -----------------------------------------------------------------------------
# SECTION 4: Assign Permissions
# -----------------------------------------------------------------------------
echo "[4/6] Assigning permissions..."

# Set ownership
chown -R root:developers "$PROJECT_DIR"

# developers: read/write (no execute on files)
chmod 775 "$PROJECT_DIR"
chmod -R 664 "$PROJECT_DIR/configs"
chmod -R 664 "$PROJECT_DIR/deployments"
chmod -R 664 "$PROJECT_DIR/reports"

# devopsadmin: full permissions via sudoers
echo "devopsadmin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devopsadmin
chmod 440 /etc/sudoers.d/devopsadmin
echo "  [OK] Permissions assigned"

# -----------------------------------------------------------------------------
# SECTION 5: Backup Configuration Files with Timestamps
# -----------------------------------------------------------------------------
echo "[5/6] Backing up configuration files..."

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$PROJECT_DIR/backup"

cp "$PROJECT_DIR/configs/deployment.yaml" "$BACKUP_DIR/deployment_${TIMESTAMP}.yaml"
cp "$PROJECT_DIR/configs/pipeline.yaml"   "$BACKUP_DIR/pipeline_${TIMESTAMP}.yaml"
cp "$PROJECT_DIR/configs/security.conf"   "$BACKUP_DIR/security_${TIMESTAMP}.conf"

echo "  [OK] Files backed up with timestamp: $TIMESTAMP"

# -----------------------------------------------------------------------------
# SECTION 6: Process Management Demo
# -----------------------------------------------------------------------------
echo "[6/6] Process management demo..."

# Create a background process
echo "  Starting background process..."
sleep 300 &
BG_PID=$!
echo "  [OK] Background process started with PID: $BG_PID"

# Display running processes
echo "  Current running processes (top 10):"
ps aux --sort=-%cpu | head -10

# Show parent-child relationships
echo "  Process tree (parent-child relationships):"
pstree -p $$ 2>/dev/null || ps -ef | grep -E "(PID|$$)" | head -20

# Terminate background process
kill $BG_PID 2>/dev/null && echo "  [OK] Background process PID $BG_PID terminated"

# -----------------------------------------------------------------------------
# SECTION 7: Create Compressed Archive
# -----------------------------------------------------------------------------
echo "Creating compressed archive..."

ARCHIVE_NAME="company-devops-platform_${TIMESTAMP}.tar.gz"
tar -czf "/tmp/$ARCHIVE_NAME" -C /opt company-devops-platform

echo "  [OK] Archive created: /tmp/$ARCHIVE_NAME"

# -----------------------------------------------------------------------------
# Display Project Structure
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
echo " Complete Project Structure"
echo "========================================="
find "$PROJECT_DIR" | sort | sed 's|[^/]*/|  |g;s|  \([^ ]\)|- \1|'

echo ""
echo "========================================="
echo " Setup Complete!"
echo "========================================="
