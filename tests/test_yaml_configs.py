"""Unit tests — validate all YAML config files are well-formed and contain expected keys."""
import os
import glob
import yaml
import pytest


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)


# ── Discover all YAML files in repo (excluding .github internals) ──────────────
YAML_FILES = [
    f for f in glob.glob("**/*.yaml", recursive=True) + glob.glob("**/*.yml", recursive=True)
    if ".git" not in f
]


@pytest.mark.parametrize("filepath", YAML_FILES)
def test_yaml_is_valid(filepath):
    """Every YAML file in the repo must parse without error."""
    try:
        data = load_yaml(filepath)
        assert data is not None or True  # empty YAML (None) is still valid
    except yaml.YAMLError as exc:
        pytest.fail(f"{filepath} is not valid YAML: {exc}")


def test_deployment_yaml_has_required_keys():
    """configs/deployment.yaml must contain apiVersion, kind, metadata, spec."""
    data = load_yaml("configs/deployment.yaml")
    for key in ["apiVersion", "kind", "metadata", "spec"]:
        assert key in data, f"Missing key '{key}' in configs/deployment.yaml"


def test_deployment_yaml_non_root():
    """Security: deployment must enforce runAsNonRoot."""
    data = load_yaml("configs/deployment.yaml")
    sc = data["spec"]["template"]["spec"].get("securityContext", {})
    assert sc.get("runAsNonRoot") is True, "runAsNonRoot must be True"


def test_deployment_yaml_no_privileged():
    """Security: no container must be privileged."""
    data = load_yaml("configs/deployment.yaml")
    for container in data["spec"]["template"]["spec"]["containers"]:
        csc = container.get("securityContext", {})
        assert csc.get("privileged") is not True, \
            f"Container '{container['name']}' must not be privileged"


def test_deployment_yaml_image_has_tag():
    """Policy: container image must have an explicit version tag (not 'latest')."""
    data = load_yaml("configs/deployment.yaml")
    for container in data["spec"]["template"]["spec"]["containers"]:
        image = container.get("image", "")
        assert ":" in image, f"Container '{container['name']}' image has no tag: {image}"
        assert not image.endswith(":latest"), \
            f"Container '{container['name']}' uses forbidden ':latest' tag"


def test_deployment_yaml_resource_limits():
    """Policy: every container must declare resource limits."""
    data = load_yaml("configs/deployment.yaml")
    for container in data["spec"]["template"]["spec"]["containers"]:
        limits = container.get("resources", {}).get("limits")
        assert limits, f"Container '{container['name']}' is missing resource limits"


def test_pipeline_yaml_has_stages():
    """configs/pipeline.yaml must define pipeline stages."""
    data = load_yaml("configs/pipeline.yaml")
    assert "pipeline" in data
    assert "stages" in data["pipeline"], "pipeline.yaml must define stages"
    stage_names = [s["name"] for s in data["pipeline"]["stages"]]
    required = {"checkout", "build", "test", "security-scan", "deploy"}
    for name in required:
        assert name in stage_names, f"Missing stage '{name}' in pipeline.yaml"


def test_app_deployment_yaml_replicas():
    """Deployment must have at least 2 replicas."""
    data = load_yaml("deployments/app-deployment.yaml")
    replicas = data["spec"]["replicas"]
    assert replicas >= 2, f"Expected >= 2 replicas, got {replicas}"
