# DevOps CI/CD Security & Version Control Management System

![CI/CD Pipeline](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/cicd-pipeline.yml/badge.svg)

## Overview
This repository implements a complete DevOps workflow covering:
- Linux Administration & User Management
- Git & GitHub Collaboration
- CI/CD Pipeline (GitHub Actions)
- SonarQube Integration
- Open Policy Agent (OPA) Policy Enforcement

---

## Repository Structure

```
devops-cicd-security-platform/
├── company-devops-platform/
│   ├── configs/
│   │   ├── deployment.yaml
│   │   ├── pipeline.yaml
│   │   └── security.conf
│   ├── deployments/
│   ├── policies/
│   └── reports/
├── linux-setup/
│   └── setup.sh
├── configs/
│   ├── deployment.yaml
│   ├── pipeline.yaml
│   └── security.conf
├── deployments/
│   └── app-deployment.yaml
├── policies/
│   ├── deployment-validation.rego
│   ├── security-validation.rego
│   └── container-validation.rego
├── reports/
│   └── sonarqube/
├── artifacts/
├── .github/
│   └── workflows/
│       ├── cicd-pipeline.yml
│       └── production-deploy.yml
└── sonarqube/
    └── sonar-project.properties
```

---

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable production-ready code |
| `production` | Deployment-ready releases |
| `staging` | Pre-production integration testing |
| `development` | Active feature development |

### Workflow
1. Developers push to `development` branch
2. CI/CD pipeline triggers automatically on push to `development`
3. After testing, merge `development` → `staging` for integration testing
4. After QA approval, merge `staging` → `production`
5. Production deployment workflow triggers on merge to `production`

### Git Commands Reference
```bash
# Stash uncommitted changes
git stash
git stash pop

# Cherry-pick a specific commit
git cherry-pick <commit-hash>

# Rebase branch onto main
git rebase main

# Revert a commit (safe undo)
git revert <commit-hash>

# Reset to previous commit (destructive)
git reset --hard HEAD~1

# Restore deleted file
git checkout HEAD -- <file-path>

# Graphical commit history
git log --oneline --graph --all
```

---

## Linux Administration

See [`linux-setup/setup.sh`](./linux-setup/setup.sh) for the full script.

### Users & Groups
- **Users**: `developer`, `tester`, `devopsadmin`
- **Groups**: `developers` (developer + tester), `operations` (devopsadmin)
- **Permissions**: developers → read/write; devopsadmin → full admin

---

## CI/CD Pipeline

Using **GitHub Actions** with stages:
1. Source Checkout
2. Build
3. Test
4. Security Validation (OPA + SonarQube)
5. Deployment

Pipeline triggers on push to `development` branch. Production workflow triggers on push to `production` branch.

---

## SonarQube Integration

- Scans YAML files, shell scripts, and application source code
- Quality gate configured — pipeline fails if gate not met
- Reports saved to `reports/sonarqube/`

See [`sonarqube/sonar-project.properties`](./sonarqube/sonar-project.properties)

---

## Open Policy Agent (OPA)

Policies enforce:
- No insecure deployments
- No root user execution
- Image version tagging required
- No privileged container execution

All policy files in [`policies/`](./policies/)

Validate with:
```bash
conftest test deployments/app-deployment.yaml --policy policies/
```

---

## Environment Variables & Secrets

Secrets are stored in **GitHub Actions Secrets** (Settings → Secrets):
- `SONAR_TOKEN` — SonarQube authentication token
- `SONAR_HOST_URL` — SonarQube server URL
- `DEPLOY_KEY` — Deployment SSH key
- `REGISTRY_USERNAME` / `REGISTRY_PASSWORD` — Container registry credentials

---

## Setup Instructions

```bash
# 1. Clone the repository
git clone https://github.com/rajubandar/devops-cicd-security-platform.git
cd devops-cicd-security-platform

# 2. Run Linux setup script (as root/sudo)
sudo bash linux-setup/setup.sh

# 3. Install OPA/Conftest
brew install conftest   # macOS
# or
wget https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_Linux_x86_64.tar.gz

# 4. Validate policies
conftest test deployments/app-deployment.yaml --policy policies/

# 5. Run SonarQube scan (requires SonarQube server)
sonar-scanner -Dproject.settings=sonarqube/sonar-project.properties
```
