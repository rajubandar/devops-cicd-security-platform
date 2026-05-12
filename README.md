# DevOps CI/CD Security & Version Control Management System

![CI/CD Pipeline](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/ci-cd-pipeline.yml/badge.svg)
![Production Deploy](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/production-deploy.yml/badge.svg)
![OPA Policy Check](https://github.com/rajubandar/devops-cicd-security-platform/actions/workflows/opa-policy-check.yml/badge.svg)

## Project Overview

This project implements a complete DevOps workflow covering:
- Linux administration & user management
- Git & GitHub collaboration with branching strategy
- CI/CD automation using GitHub Actions
- SonarQube code quality integration
- Open Policy Agent (OPA) policy enforcement

---

## Outputs

| Output | Location |
|---|---|
| GitHub Repository | https://github.com/rajubandar/devops-cicd-security-platform |
| Linux Configuration Structure | `linux-config/` |
| CI/CD Pipeline Configuration | `.github/workflows/ci-cd-pipeline.yml` |
| SonarQube Reports | `reports/sonarqube/sonar-report.json` |
| OPA Policies | `policies/` |
| Validation Reports | `reports/opa-validation-report.json`, `reports/validation-summary.json` |
| Deployment Logs | `reports/deployment-log.json`, `artifacts/deploy-log.json` |
| README Documentation | This file |

---

## Branching Strategy

```
feature/* → development → staging → production → main
```

| Branch | Purpose | CI Trigger |
|---|---|---|
| `main` | Stable reference | Manual |
| `development` | Active development | Auto on push |
| `staging` | Pre-prod testing | Merge from dev |
| `production` | Live deployments | Separate workflow |

---

## Project Directory Structure

```
company-devops-platform/
├── configs/          ← deployment.yaml, pipeline.yaml, security.conf
├── deployments/      ← Kubernetes manifests
├── policies/         ← OPA Rego policies
├── reports/          ← SonarQube + OPA + deployment reports
├── artifacts/        ← Build + test + deploy artifacts
├── backup/           ← Timestamped config backups
├── scripts/          ← Linux setup + rollback scripts
└── src/              ← Application source code
```

See full structure: [`linux-config/directory-structure.txt`](linux-config/directory-structure.txt)

---

## 1. Linux Administration

Script: [`scripts/linux-setup.sh`](scripts/linux-setup.sh)

- Creates `company-devops-platform/` with subdirectories: `configs`, `deployments`, `policies`, `reports`
- **Users**: `developer`, `tester`, `devopsadmin`
- **Groups**: `developers` (developer + tester), `operations` (devopsadmin)
- **Permissions**: read/write for developers group, full admin for devopsadmin
- Timestamped config backups in `backup/`
- Background process creation and termination demo
- Compressed archive: `company-devops-platform_<timestamp>.tar.gz`

See output: [`linux-config/linux-setup-output.txt`](linux-config/linux-setup-output.txt)

---

## 2. Git & GitHub Workflow

See: [`docs/git-workflow.md`](docs/git-workflow.md)

### Demonstrated Operations

```bash
# Stash
git stash push -m "WIP: feature"
git stash pop

# Cherry-pick
git cherry-pick <commit-sha>

# Rebase
git rebase main
git rebase -i HEAD~3

# Revert
git revert HEAD

# Reset
git reset --soft HEAD~1
git reset --hard HEAD~1

# Restore deleted file
git checkout <sha>^ -- <deleted-file>

# Graphical history
git log --oneline --graph --decorate --all
```

---

## 3. CI/CD Pipeline (GitHub Actions)

Workflow: [`.github/workflows/ci-cd-pipeline.yml`](.github/workflows/ci-cd-pipeline.yml)

| Stage | Description |
|---|---|
| Source Checkout | Checkout code, validate structure |
| Build | Build app, create build-info.json |
| Test | pytest unit tests + YAML validation |
| Security Validation | SonarQube scan + OPA policy check |
| Deploy to Development | Deploy + generate deployment log |
| Rollback on Failure | Auto rollback if deploy fails |

- **Trigger**: Push to `development` branch
- **Production deploy**: Separate workflow (`.github/workflows/production-deploy.yml`)
- **Artifacts**: Stored in `artifacts/`
- **Rollback**: [`scripts/rollback.sh`](scripts/rollback.sh)

---

## 4. SonarQube Integration

Config: [`sonar-project.properties`](sonar-project.properties)

- Scans: `src/`, `scripts/`, `configs/`
- Quality gate enforced (`sonar.qualitygate.wait=true`)
- Reports saved to `reports/sonarqube/`

### Report Summary

| Metric | Value |
|---|---|
| Bugs | 0 |
| Vulnerabilities | 0 |
| Code Smells | 2 |
| Duplications | 0% |
| Coverage | 85% |
| Quality Gate | ✅ OK |

Full report: [`reports/sonarqube/sonar-report.json`](reports/sonarqube/sonar-report.json)

> **Setup**: Add `SONAR_TOKEN` and `SONAR_HOST_URL` in GitHub → Settings → Secrets and variables → Actions

---

## 5. Open Policy Agent (OPA)

Policies: [`policies/`](policies/)

| Policy File | Enforces |
|---|---|
| `deployment_validation.rego` | No missing securityContext, resource limits, health probes |
| `security_validation.rego` | No root user (UID 0), runAsNonRoot required |
| `container_validation.rego` | No privileged containers, no `:latest` tag, explicit version required |

Validation report: [`reports/opa-validation-report.json`](reports/opa-validation-report.json)

---

## Environment Variables & Secrets

Configure in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `SONAR_TOKEN` | SonarQube auth token |
| `SONAR_HOST_URL` | SonarQube server URL |
| `DEPLOY_KEY` | Deployment SSH key |

---

## Quick Start

```bash
git clone https://github.com/rajubandar/devops-cicd-security-platform.git
cd devops-cicd-security-platform

# Run Linux setup
bash scripts/linux-setup.sh

# Validate OPA policies
conftest verify --policy policies/

# Run SonarQube scan
sonar-scanner

# Run tests
python -m pytest src/test_app.py -v
```

---

*Assignment: DevOps CI/CD Security & Version Control Management System — KIET Group of Institutions*
