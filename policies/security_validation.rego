# =============================================================
# OPA Policy: Security Validation
# Restricts root user execution
# =============================================================
package security.validation

import future.keywords.if
import future.keywords.in

default allow := false

allow if {
    not root_user_execution
    not missing_non_root_enforcement
}

# RULE 1: Restrict root user execution (UID 0 is root)
root_user_execution if {
    input.spec.template.spec.securityContext.runAsUser == 0
}

root_user_execution if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.runAsUser == 0
}

# RULE 2: Enforce runAsNonRoot
missing_non_root_enforcement if {
    not input.spec.template.spec.securityContext.runAsNonRoot
}

missing_non_root_enforcement if {
    input.spec.template.spec.securityContext.runAsNonRoot == false
}

# Violation messages
violation[msg] if {
    root_user_execution
    msg := "SECURITY VIOLATION: Container is running as root (UID 0). This is not allowed."
}

violation[msg] if {
    missing_non_root_enforcement
    msg := "SECURITY VIOLATION: runAsNonRoot must be set to true in pod securityContext."
}
