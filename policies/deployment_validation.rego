# =============================================================
# OPA Policy: Deployment Validation
# Prevents insecure deployments
# =============================================================
package deployment.validation

import future.keywords.if
import future.keywords.in

# Default deny
default allow := false

# Allow only if all checks pass
allow if {
    not insecure_deployment
    not missing_resource_limits
    not missing_health_probes
}

# RULE 1: Prevent insecure deployments (must have security context)
insecure_deployment if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext
}

insecure_deployment if {
    not input.spec.template.spec.securityContext
}

# RULE 2: Ensure resource limits are set
missing_resource_limits if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits
}

missing_resource_limits if {
    container := input.spec.template.spec.containers[_]
    not container.resources.requests
}

# RULE 3: Ensure health probes are configured
missing_health_probes if {
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
}

missing_health_probes if {
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
}

# Violation messages
violation[msg] if {
    insecure_deployment
    msg := "VIOLATION: Deployment missing security context. All containers must have securityContext defined."
}

violation[msg] if {
    missing_resource_limits
    msg := "VIOLATION: Deployment missing resource limits/requests. Resource management is required."
}

violation[msg] if {
    missing_health_probes
    msg := "VIOLATION: Deployment missing liveness or readiness probes."
}
