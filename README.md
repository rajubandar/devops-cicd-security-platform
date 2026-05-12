# DevOps CI/CD Security & Version Control Management System

![CI/CD Pipeline](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/ci-cd-pipeline.yml/badge.svg)
![Production Deploy](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/production-deploy.yml/badge.svg)
![OPA Policy Check](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/opa-policy-check.yml/badge.svg)

## Project Overview

This project implements a full DevOps workflow covering Linux administration, Git & GitHub collaboration, CI/CD automation using GitHub Actions, SonarQube code quality integration, and Open Policy Agent (OPA) policy enforcement.

---

## Branching Strategy

| Branch | Purpose | Trigger |
|---|---|---|
| `main` | Production-ready code | Manual merge from staging |
| `development` | Active feature development | Auto CI on every push |
| `staging` | Pre-production testing | Merge from development |
| `production` | Live production deployments | Separate deploy workflow |

### Branch Flow
```
feature/* → development → staging → production → main
```

- **development**: All new features and bug fixes are pushed here. CI pipeline (build, test, security scan) triggers automatically.
- **staging**: Integration testing and SonarQube quality gate validation.
- **production**: Only stable, gate-passing code is deployed. Rollback mechanism is configured.
- **main**: Mirrors production for reference and documentation.

---

## Project Directory Structure

```
company-devops-platform/
├── configs/
│   ├── deployment.yaml
│   ├── pipeline.yaml
│   └── security.conf
├── deployments/
│   └── app-deployment.yaml
├── policies/
│   ├── deployment_validation.rego
│   ├── security_validation.rego
│   └── container_validation.rego
├── reports/
│   └── sonarqube/
│       └── sonar-report.json
├── artifacts/
├── scripts/
│   ├── linux-setup.sh
│   └── rollback.sh
├── src/
│   └── app.py
├── sonar-project.properties
└── README.md
```

---

## Requirements

### 1. Linux Administration & User Management

See [`scripts/linux-setup.sh`](scripts/linux-setup.sh) for complete automation of:
- Project directory creation (`company-devops-platform` with `configs`, `deployments`, `policies`, `reports`)
- User creation: `developer`, `tester`, `devopsadmin`
- Group creation: `developers`, `operations`
- Permission assignment (read/write for developers, full admin for devopsadmin)
- Config file creation, backup with timestamps
- Background process management
- Compressed archive creation

### 2. Git & GitHub Workflow

- Branches: `development`, `staging`, `production`
- Separate commits per concern (Linux setup, Git workflow, CI/CD, SonarQube, OPA)
- Merge conflict simulation and resolution documented in [`docs/git-workflow.md`](docs/git-workflow.md)
- Git operations demonstrated: `stash`, `cherry-pick`, `rebase`, `revert`, `reset`

### 3. CI/CD Pipeline (GitHub Actions)

See [`.github/workflows/ci-cd-pipeline.yml`](.github/workflows/ci-cd-pipeline.yml):
- Stages: Source Checkout → Build → Test → Security Validation → Deployment
- Triggers on push to `development`
- Separate production workflow for `production` branch
- Rollback on failed deployment
- Artifacts stored in `artifacts/`

### 4. SonarQube Integration

See [`.github/workflows/ci-cd-pipeline.yml`](.github/workflows/ci-cd-pipeline.yml) SonarQube job:
- Scans YAML files, shell scripts, and source code
- Reports: bugs, vulnerabilities, code smells, duplicated code
- Quality gate enforced — pipeline fails if gate fails
- Reports saved to `reports/sonarqube/`

### 5. Open Policy Agent (OPA)

See [`policies/`](policies/) directory:
- [`deployment_validation.rego`](policies/deployment_validation.rego) — prevents insecure deployments
- [`security_validation.rego`](policies/security_validation.rego) — restricts root user execution
- [`container_validation.rego`](policies/container_validation.rego) — enforces image tagging and no privileged containers
- Validation reports generated; deployment fails on policy violation

---

## Environment Variables & Secrets

Configured in GitHub repository **Settings → Secrets and variables → Actions**:

| Secret Name | Description |
|---|---|
| `SONAR_TOKEN` | SonarQube authentication token |
| `SONAR_HOST_URL` | SonarQube server URL |
| `DEPLOY_KEY` | Deployment SSH key |
| `PROD_DEPLOY_KEY` | Production deployment key |

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rajubandar/devops-cicd-security-platform.git
cd devops-cicd-security-platform

# Run Linux setup script
bash scripts/linux-setup.sh

# Validate OPA policies
conftest verify --policy policies/

# Run SonarQube scan locally
sonar-scanner
```

---

*Assignment: DevOps CI/CD Security & Version Control Management System*
