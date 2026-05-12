# Artifacts Directory

This directory stores CI/CD pipeline build artifacts, deployment packages, and logs.

## Contents

```
artifacts/
├── builds/          # Docker images and build outputs
├── test-results/    # Test execution reports (JUnit XML, coverage)
├── deployment-logs/ # Deployment execution logs
└── rollback/        # Rollback packages
```

## Artifact Retention

- Build artifacts: 30 days
- Deployment logs: 90 days
- Test results: 30 days

## Download

Artifacts are automatically uploaded by GitHub Actions and can be downloaded from the **Actions** tab of the repository.
