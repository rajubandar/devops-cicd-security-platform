# =============================================================================
# OPA Policy: Deployment Validation
# Validates Kubernetes deployment manifests
# =============================================================================

package deployment.validation

import future.keywords.if
import future.keywords.in

# Default deny
default allow := false

# Allow if all checks pass
allow if {
    not deny_missing_replicas
    not deny_missing_labels
    not deny_missing_resource_limits
}

# -------------------------------------------------------
# RULE 1: Minimum replicas required
# -------------------------------------------------------
deny_missing_replicas if {
    input.spec.replicas < 2
}

violation[msg] {
    input.spec.replicas < 2
    msg := sprintf("VIOLATION: Deployment '%v' must have at least 2 replicas. Current: %v",
        [input.metadata.name, input.spec.replicas])
}

# -------------------------------------------------------
# RULE 2: Required labels
# -------------------------------------------------------
deny_missing_labels if {
    not input.metadata.labels.app
}

violation[msg] {
    not input.metadata.labels.app
    msg := sprintf("VIOLATION: Deployment '%v' is missing required label 'app'",
        [input.metadata.name])
}

deny_missing_labels if {
    not input.metadata.labels.version
}

violation[msg] {
    not input.metadata.labels.version
    msg := sprintf("VIOLATION: Deployment '%v' is missing required label 'version'",
        [input.metadata.name])
}

# -------------------------------------------------------
# RULE 3: Resource limits must be set
# -------------------------------------------------------
deny_missing_resource_limits if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits
    msg := sprintf("VIOLATION: Container '%v' in deployment '%v' is missing resource limits",
        [container.name, input.metadata.name])
}

# -------------------------------------------------------
# RULE 4: Health probes required
# -------------------------------------------------------
violation[msg] {
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf("WARNING: Container '%v' is missing readinessProbe",
        [container.name])
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf("WARNING: Container '%v' is missing livenessProbe",
        [container.name])
}
