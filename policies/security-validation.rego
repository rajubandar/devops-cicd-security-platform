# =============================================================================
# OPA Policy: Security Validation
# Enforces security best practices for Kubernetes deployments
# =============================================================================

package security.validation

import future.keywords.if
import future.keywords.in

# Default deny
default allow := false

# Allow if all security checks pass
allow if {
    not deny_root_user
    not deny_privileged_container
    not deny_host_network
    not deny_host_pid
}

# -------------------------------------------------------
# RULE 1: Prevent root user execution
# -------------------------------------------------------
deny_root_user if {
    input.spec.template.spec.securityContext.runAsUser == 0
}

deny_root_user if {
    not input.spec.template.spec.securityContext.runAsNonRoot
}

violation[msg] {
    input.spec.template.spec.securityContext.runAsUser == 0
    msg := sprintf("SECURITY VIOLATION: Deployment '%v' runs as root (UID 0). Use a non-root user.",
        [input.metadata.name])
}

violation[msg] {
    not input.spec.template.spec.securityContext.runAsNonRoot
    msg := sprintf("SECURITY VIOLATION: Deployment '%v' does not enforce runAsNonRoot: true",
        [input.metadata.name])
}

# -------------------------------------------------------
# RULE 2: Prevent privileged container execution
# -------------------------------------------------------
deny_privileged_container if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("SECURITY VIOLATION: Container '%v' in deployment '%v' is running in privileged mode.",
        [container.name, input.metadata.name])
}

# -------------------------------------------------------
# RULE 3: Prevent privilege escalation
# -------------------------------------------------------
deny_privilege_escalation if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := sprintf("SECURITY VIOLATION: Container '%v' allows privilege escalation.",
        [container.name])
}

# -------------------------------------------------------
# RULE 4: Prevent host network access
# -------------------------------------------------------
deny_host_network if {
    input.spec.template.spec.hostNetwork == true
}

violation[msg] {
    input.spec.template.spec.hostNetwork == true
    msg := sprintf("SECURITY VIOLATION: Deployment '%v' uses hostNetwork: true",
        [input.metadata.name])
}

# -------------------------------------------------------
# RULE 5: Prevent host PID access
# -------------------------------------------------------
deny_host_pid if {
    input.spec.template.spec.hostPID == true
}

violation[msg] {
    input.spec.template.spec.hostPID == true
    msg := sprintf("SECURITY VIOLATION: Deployment '%v' uses hostPID: true",
        [input.metadata.name])
}
