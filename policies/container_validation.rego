# =============================================================
# OPA Policy: Container Validation
# Enforces image version tagging & prevents privileged containers
# =============================================================
package container.validation

import future.keywords.if
import future.keywords.in

default allow := false

allow if {
    not privileged_container
    not missing_image_tag
    not latest_image_tag
    not privilege_escalation_allowed
}

# RULE 1: Prevent privileged container execution
privileged_container if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
}

# RULE 2: Enforce image version tagging (image must have a tag)
missing_image_tag if {
    container := input.spec.template.spec.containers[_]
    image := container.image
    not contains(image, ":")
}

# RULE 3: Prevent :latest tag usage
latest_image_tag if {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
}

# RULE 4: Prevent privilege escalation
privilege_escalation_allowed if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
}

# Violation messages
violation[msg] if {
    privileged_container
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("CONTAINER VIOLATION: Container '%v' is running in privileged mode. This is not allowed.", [container.name])
}

violation[msg] if {
    missing_image_tag
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("CONTAINER VIOLATION: Container '%v' image '%v' has no version tag. Explicit version tags are required.", [container.name, container.image])
}

violation[msg] if {
    latest_image_tag
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("CONTAINER VIOLATION: Container '%v' uses ':latest' tag. Pin to a specific version.", [container.name])
}

violation[msg] if {
    privilege_escalation_allowed
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := sprintf("CONTAINER VIOLATION: Container '%v' allows privilege escalation. Set allowPrivilegeEscalation: false.", [container.name])
}
