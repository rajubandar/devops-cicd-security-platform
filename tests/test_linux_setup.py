"""Unit tests — validate linux-setup/setup.sh structure and content."""
import os
import re
import pytest

SCRIPT = "linux-setup/setup.sh"


def script_content():
    with open(SCRIPT) as f:
        return f.read()


def test_setup_script_exists():
    assert os.path.isfile(SCRIPT), f"Missing: {SCRIPT}"


def test_setup_script_creates_project_dir():
    content = script_content()
    assert "company-devops-platform" in content


def test_setup_script_creates_required_subdirs():
    content = script_content()
    for d in ["configs", "deployments", "policies", "reports"]:
        assert d in content, f"setup.sh must create the '{d}' subdirectory"


def test_setup_script_creates_users():
    content = script_content()
    for user in ["developer", "tester", "devopsadmin"]:
        assert user in content, f"setup.sh must create user '{user}'"


def test_setup_script_creates_groups():
    content = script_content()
    for group in ["developers", "operations"]:
        assert group in content, f"setup.sh must create group '{group}'"


def test_setup_script_has_backup_step():
    content = script_content()
    assert "backup" in content.lower()
    assert "TIMESTAMP" in content or "timestamp" in content.lower()


def test_setup_script_has_archive_step():
    content = script_content()
    assert "tar" in content and ".tar.gz" in content


def test_setup_script_has_background_process():
    content = script_content()
    assert "&" in content        # background launch
    assert "kill" in content     # termination


def test_setup_script_has_shebang():
    content = script_content()
    assert content.startswith("#!/bin/bash"), "setup.sh must have #!/bin/bash shebang"
