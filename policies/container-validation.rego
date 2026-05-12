# =============================================================================
# OPA Policy: Container Validation
# Enforces container image and configuration policies
# =============================================================================

package container.validation

import future.keywords.if
import future.keywords.in

# Default deny
default allow := false

# Allow if all container checks pass
allow if {
    not deny_latest_image_tag
    not deny_unapproved_registry
}

# Approved container registries
approved_registries := [
    "myregistry.azurecr.io",
    "gcr.io",
    "public.ecr.aws",
    "myregistry"
]

# -------------------------------------------------------
# RULE 1: Enforce image version tagging (no 'latest')
# -------------------------------------------------------
deny_latest_image_tag if {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
}

deny_latest_image_tag if {
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("CONTAINER VIOLATION: Container '%v' uses 'latest' image tag. Specify an explicit version tag.",
        [container.name])
}

violation[msg] {
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("CONTAINER VIOLATION: Container '%v' image '%v' has no version tag.",
        [container.name, container.image])
}

# -------------------------------------------------------
# RULE 2: Require imagePullPolicy: Always for tagged images
# -------------------------------------------------------
violation[msg] {
    container := input.spec.template.spec.containers[_]
    container.imagePullPolicy != "Always"
    msg := sprintf("CONTAINER WARNING: Container '%v' should use imagePullPolicy: Always",
        [container.name])
}

# -------------------------------------------------------
# RULE 3: Require read-only root filesystem
# -------------------------------------------------------
violation[msg] {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := sprintf("CONTAINER VIOLATION: Container '%v' does not use readOnlyRootFilesystem: true",
        [container.name])
}

# -------------------------------------------------------
# RULE 4: Require capability drops
# -------------------------------------------------------
violation[msg] {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.capabilities.drop
    msg := sprintf("CONTAINER VIOLATION: Container '%v' does not drop Linux capabilities.",
        [container.name])
}
