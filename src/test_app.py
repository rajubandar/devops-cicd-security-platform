#!/usr/bin/env python3
import unittest
import json
import sys
import os


class TestDevOpsPlatform(unittest.TestCase):

    def test_python_version(self):
        self.assertGreaterEqual(sys.version_info.major, 3)

    def test_json_serialization(self):
        data = {"status": "healthy", "version": "1.0.0"}
        result = json.dumps(data)
        self.assertIn("healthy", result)

    def test_configs_dir_exists(self):
        self.assertTrue(os.path.isdir("configs"))

    def test_deployment_yaml_exists(self):
        self.assertTrue(os.path.isfile("configs/deployment.yaml"))

    def test_pipeline_yaml_exists(self):
        self.assertTrue(os.path.isfile("configs/pipeline.yaml"))

    def test_security_conf_exists(self):
        self.assertTrue(os.path.isfile("configs/security.conf"))

    def test_policies_dir_exists(self):
        self.assertTrue(os.path.isdir("policies"))

    def test_scripts_dir_exists(self):
        self.assertTrue(os.path.isdir("scripts"))

    def test_deployments_dir_exists(self):
        self.assertTrue(os.path.isdir("deployments"))

    def test_sonar_properties_exists(self):
        self.assertTrue(os.path.isfile("sonar-project.properties"))


if __name__ == '__main__':
    unittest.main()
