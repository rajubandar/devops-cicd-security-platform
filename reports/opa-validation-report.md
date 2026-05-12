# OPA Policy Validation Report

**Generated:** 2026-05-12  
**Tool:** Conftest v0.50.0  
**Policy Directory:** `policies/`  
**Target:** `deployments/app-deployment.yaml`

---

## Validation Summary

| Policy File | Status | Violations |
|-------------|--------|------------|
| `deployment-validation.rego` | ✅ PASS | 0 |
| `security-validation.rego` | ✅ PASS | 0 |
| `container-validation.rego` | ✅ PASS | 0 |

**Overall Result: ✅ ALL POLICIES PASSED**

---

## Policy Checks Performed

### Deployment Validation
- ✅ Replicas ≥ 2: **3 replicas** configured
- ✅ Required label `app`: present
- ✅ Required label `version`: present  
- ✅ Resource limits: memory `256Mi`, CPU `500m`

### Security Validation
- ✅ `runAsNonRoot: true` enforced
- ✅ `runAsUser: 1000` (non-root)
- ✅ `privileged: false` set
- ✅ `allowPrivilegeEscalation: false` set
- ✅ `hostNetwork` not enabled
- ✅ `hostPID` not enabled

### Container Validation
- ✅ Image tag `v1.2.3` is explicit (not `latest`)
- ✅ `imagePullPolicy: Always` set
- ✅ `readOnlyRootFilesystem: true` set
- ✅ Linux capabilities dropped

---

## Command Used

```bash
conftest test deployments/app-deployment.yaml \
  --policy policies/ \
  --output table
```

---

## Failed Deployment Example

If a policy is violated, the pipeline fails with:

```
FAIL - deployments/app-deployment.yaml - container.validation
CONTAINER VIOLATION: Container 'app' uses 'latest' image tag.

1 test, 0 passed, 0 warnings, 1 failure, 0 exceptions
```

The deployment is blocked until the violation is resolved.
