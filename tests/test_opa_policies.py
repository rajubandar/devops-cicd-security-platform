"""Unit tests — verify OPA .rego policy files exist and contain expected rules."""
import os
import re
import pytest

POLICY_DIR = "policies"

REQUIRED_POLICY_FILES = [
    "deployment-validation.rego",
    "security-validation.rego",
    "container-validation.rego",
]


@pytest.mark.parametrize("filename", REQUIRED_POLICY_FILES)
def test_policy_file_exists(filename):
    path = os.path.join(POLICY_DIR, filename)
    assert os.path.isfile(path), f"Missing policy file: {path}"


@pytest.mark.parametrize("filename", REQUIRED_POLICY_FILES)
def test_policy_file_not_empty(filename):
    path = os.path.join(POLICY_DIR, filename)
    assert os.path.getsize(path) > 0, f"Policy file is empty: {path}"


def read_policy(filename):
    with open(os.path.join(POLICY_DIR, filename)) as f:
        return f.read()


def test_deployment_policy_has_package():
    content = read_policy("deployment-validation.rego")
    assert "package deployment.validation" in content


def test_deployment_policy_denies_low_replicas():
    content = read_policy("deployment-validation.rego")
    assert "replicas" in content, "deployment policy must check replicas"


def test_security_policy_has_package():
    content = read_policy("security-validation.rego")
    assert "package security.validation" in content


def test_security_policy_denies_root():
    content = read_policy("security-validation.rego")
    assert "runAsNonRoot" in content or "runAsUser" in content, \
        "security policy must restrict root user"


def test_security_policy_denies_privileged():
    content = read_policy("security-validation.rego")
    assert "privileged" in content, "security policy must deny privileged containers"


def test_container_policy_has_package():
    content = read_policy("container-validation.rego")
    assert "package container.validation" in content


def test_container_policy_denies_latest_tag():
    content = read_policy("container-validation.rego")
    assert "latest" in content, "container policy must deny :latest image tags"


def test_all_policies_have_violation_rule():
    for filename in REQUIRED_POLICY_FILES:
        content = read_policy(filename)
        assert "violation" in content, \
            f"{filename} must define a 'violation' rule used by conftest"
