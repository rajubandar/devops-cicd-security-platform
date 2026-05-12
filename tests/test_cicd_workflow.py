"""Unit tests — validate GitHub Actions workflow files."""
import os
import yaml
import pytest

WORKFLOW_DIR = ".github/workflows"


def load_workflow(filename):
    path = os.path.join(WORKFLOW_DIR, filename)
    with open(path) as f:
        return yaml.safe_load(f)


def test_cicd_pipeline_exists():
    assert os.path.isfile(os.path.join(WORKFLOW_DIR, "cicd-pipeline.yml"))


def test_production_workflow_exists():
    assert os.path.isfile(os.path.join(WORKFLOW_DIR, "production-deploy.yml"))


def test_cicd_triggers_on_development_branch():
    wf = load_workflow("cicd-pipeline.yml")
    branches = wf["on"]["push"]["branches"]
    assert "development" in branches or "main" in branches


def test_production_triggers_on_production_branch():
    wf = load_workflow("production-deploy.yml")
    branches = wf["on"]["push"]["branches"]
    assert "production" in branches


def test_cicd_has_required_jobs():
    wf = load_workflow("cicd-pipeline.yml")
    jobs = list(wf["jobs"].keys())
    for required in ["checkout", "build", "test", "security-validation", "deploy"]:
        assert required in jobs, f"Missing job '{required}' in cicd-pipeline.yml"


def test_cicd_has_rollback_job():
    wf = load_workflow("cicd-pipeline.yml")
    assert "rollback" in wf["jobs"]
    assert wf["jobs"]["rollback"]["if"] == "failure()"


def test_production_has_pre_validation():
    wf = load_workflow("production-deploy.yml")
    assert "pre-deploy-validation" in wf["jobs"]


def test_production_has_environment():
    wf = load_workflow("production-deploy.yml")
    env = wf["jobs"]["deploy-production"]["environment"]
    assert env["name"] == "production"


def test_artifacts_uploaded_in_build():
    wf = load_workflow("cicd-pipeline.yml")
    build_steps = [s["name"] for s in wf["jobs"]["build"]["steps"] if "name" in s]
    assert any("artifact" in n.lower() or "upload" in n.lower() for n in build_steps)
