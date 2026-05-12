# DevOps CI/CD Security & Version Control Management System

[![CI/CD Pipeline](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/cicd-pipeline.yml/badge.svg)](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/cicd-pipeline.yml)
[![Production Deployment](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/production-deploy.yml/badge.svg)](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/production-deploy.yml)

> **Stack:** Linux · Git/GitHub · GitHub Actions · SonarQube · Open Policy Agent (OPA/Conftest) · Kubernetes · Python/pytest

---

## Repository Structure

```
devops-cicd-security-platform/
├── .github/workflows/
│   ├── cicd-pipeline.yml          # CI/CD: push → development
│   └── production-deploy.yml      # CD:   push → production
├── linux-setup/
│   └── setup.sh                   # Full Linux admin setup script
├── git-workflow/
│   └── git-commands-demo.sh       # Git stash/cherry-pick/rebase/revert demo
├── configs/
│   ├── deployment.yaml            # Kubernetes Deployment manifest
│   ├── pipeline.yaml              # Pipeline definition
│   └── security.conf              # Security policy config
├── deployments/
│   ├── app-deployment.yaml        # Production deployment manifest
│   └── staging-deployment.yaml    # Staging deployment manifest
├── policies/                      # OPA Rego policies (Conftest)
│   ├── deployment-validation.rego
│   ├── security-validation.rego
│   ├── container-validation.rego
│   └── conftest.yaml
├── sonarqube/
│   ├── sonar-project.properties
│   └── install-sonarqube.sh
├── reports/
│   ├── sonarqube/                 # SonarQube quality-gate reports
│   ├── opa-validation-report.md
│   └── deployment-logs/
├── artifacts/                     # Build/test/deploy artifacts (CI-generated)
└── tests/                         # pytest test suite (runs in CI)
    ├── test_yaml_configs.py
    ├── test_opa_policies.py
    ├── test_linux_setup.py
    └── test_cicd_workflow.py
```

---

## Branching Strategy

| Branch | Purpose | CI Trigger |
|--------|---------|------------|
| `main` | Stable default branch | CI/CD pipeline |
| `development` | Active feature development | CI/CD pipeline |
| `staging` | Integration testing | PR validation |
| `production` | Live production releases | Production deploy workflow |

### Merge Flow
```
development  →  staging  →  production
     ↓               ↓            ↓
 CI/CD runs    PR checks    Production deploy
```

### Git Operations Reference
```bash
# Branches
git checkout -b development && git push origin development
git checkout -b staging     && git push origin staging
git checkout -b production  && git push origin production

# Stash (save uncommitted work)
git stash
git stash list
git stash pop

# Cherry-pick (apply specific commit to another branch)
git cherry-pick <commit-sha>

# Rebase (replay commits on top of another branch)
git checkout development && git rebase main

# Revert (safe undo — creates new commit)
git revert <commit-sha>

# Reset (destructive undo)
git reset --hard HEAD~1

# Restore deleted file
git restore configs/deployment.yaml
# or
git checkout HEAD -- configs/deployment.yaml

# Graphical commit history
git log --oneline --graph --all --decorate
```

---

## CI/CD Pipeline (GitHub Actions)

### Trigger
- **`cicd-pipeline.yml`** — triggers on every push to `development` or `main`
- **`production-deploy.yml`** — triggers on every push to `production`

### Stages

| # | Stage | What it does |
|---|-------|--------------|
| 1 | Source Checkout | `actions/checkout@v4`, full git history, exports short SHA |
| 2 | Build | YAML lint (`yamllint`), Shell lint (`shellcheck`), build-info artifact |
| 3 | Test | `pytest` suite, YAML validation, JUnit XML + coverage XML uploaded |
| 4 | Security Validation | Conftest OPA check + secret grep scan + SonarQube (if secrets set) |
| 5 | Deploy | Simulated `kubectl apply`, deployment log artifact |
| — | Rollback | Auto-triggers on `failure()` in Deploy stage |

### Environment Secrets (Settings → Secrets and variables → Actions)

| Secret | Purpose |
|--------|---------|
| `SONAR_TOKEN` | SonarQube auth token |
| `SONAR_HOST_URL` | SonarQube server URL (e.g. `http://localhost:9000`) |
| `DEPLOY_KEY` | SSH key for deployment |
| `REGISTRY_USERNAME` | Container registry username |
| `REGISTRY_PASSWORD` | Container registry password |

> Pipeline runs fully without any secrets — SonarQube step is skipped gracefully.

---

## Linux Administration

See [`linux-setup/setup.sh`](./linux-setup/setup.sh)

```
Project directory  : /opt/company-devops-platform/
Sub-directories    : configs/  deployments/  policies/  reports/  artifacts/  backup/

Users    : developer · tester · devopsadmin
Groups   : developers (developer + tester) · operations (devopsadmin)

Permissions:
  developers   → read/write  (chmod 664)
  devopsadmin  → full sudo   (/etc/sudoers.d/devopsadmin)

Config files created:
  configs/deployment.yaml
  configs/pipeline.yaml
  configs/security.conf

Backup  : all configs copied to backup/ with timestamp suffix
Archive : /tmp/company-devops-platform_<timestamp>.tar.gz
```

Run (as root on a Linux host):
```bash
sudo bash linux-setup/setup.sh
```

---

## SonarQube Integration

See [`sonarqube/sonar-project.properties`](./sonarqube/sonar-project.properties)

- Scans YAML files, shell scripts, and application source code
- Quality gate configured — pipeline **fails** if gate not met
- Reports saved to `reports/sonarqube/`
- To enable in CI: add `SONAR_TOKEN` + `SONAR_HOST_URL` to GitHub Secrets

**Install SonarQube locally:**
```bash
sudo bash sonarqube/install-sonarqube.sh
# UI available at http://localhost:9000  (admin / admin)
```

---

## OPA Policy Enforcement

All policies in [`policies/`](./policies/)

| Policy file | Rules enforced |
|-------------|----------------|
| `deployment-validation.rego` | ≥ 2 replicas, required labels (`app`, `version`), resource limits, health probes |
| `security-validation.rego` | `runAsNonRoot: true`, no root UID, no privileged, no hostNetwork/hostPID |
| `container-validation.rego` | No `:latest` tag, explicit version required, `readOnlyRootFilesystem`, drop capabilities |

**Validate locally:**
```bash
# Install conftest
brew install conftest           # macOS
# or download from https://github.com/open-policy-agent/conftest/releases

# Run all policies
conftest test deployments/app-deployment.yaml --policy policies/ --output table
```

Pipeline **fails** automatically if any policy is violated.

---

## Running Tests Locally

```bash
pip install pytest pytest-cov pyyaml yamllint
pytest tests/ -v --tb=short
```

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/rajubandar/devops-cicd-security-platform.git
cd devops-cicd-security-platform

# 2. Create and push all branches
git checkout -b development && git push origin development
git checkout main
git checkout -b staging     && git push origin staging
git checkout main
git checkout -b production  && git push origin production
git checkout main

# 3. Run tests
pip install pytest pytest-cov pyyaml yamllint
pytest tests/ -v

# 4. Validate OPA policies
conftest test deployments/app-deployment.yaml --policy policies/

# 5. Linux setup (Linux VM/server)
sudo bash linux-setup/setup.sh
```
