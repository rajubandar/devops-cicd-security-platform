#!/bin/bash
# =============================================================================
# SonarQube Installation Script
# DevOps CI/CD Security Platform
# =============================================================================

set -e

SONAR_VERSION="10.4.1.88267"
SONAR_DIR="/opt/sonarqube"

echo "[1/4] Installing SonarQube $SONAR_VERSION..."

# Install Java (required by SonarQube)
apt-get update -q
apt-get install -y openjdk-17-jdk wget unzip

echo "[2/4] Downloading SonarQube..."
wget -q "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip" -O /tmp/sonarqube.zip
unzip -q /tmp/sonarqube.zip -d /opt/
mv "/opt/sonarqube-${SONAR_VERSION}" "$SONAR_DIR"

echo "[3/4] Configuring SonarQube..."
# Create sonar user
useradd -r -s /bin/false sonar 2>/dev/null || true
chown -R sonar:sonar "$SONAR_DIR"

# Configure sonar.properties
cat >> "$SONAR_DIR/conf/sonar.properties" << 'EOF'

# Database
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar

# Web
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF

echo "[4/4] Starting SonarQube..."
su -s /bin/bash sonar -c "$SONAR_DIR/bin/linux-x86-64/sonar.sh start"

echo ""
echo "SonarQube is starting at http://localhost:9000"
echo "Default credentials: admin / admin"
echo "IMPORTANT: Change the admin password immediately!"
