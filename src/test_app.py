#!/usr/bin/env python3
"""
Unit tests for DevOps CI/CD Security Platform application.
"""

import unittest
import json
from unittest.mock import MagicMock, patch
from io import BytesIO


class TestAppHandler(unittest.TestCase):
    """Test cases for the HTTP handler."""

    def _make_handler(self, path):
        """Create a mock handler for testing."""
        from src.app import AppHandler
        handler = AppHandler.__new__(AppHandler)
        handler.path = path
        handler.wfile = BytesIO()
        handler.send_response = MagicMock()
        handler.send_header = MagicMock()
        handler.end_headers = MagicMock()
        handler.address_string = MagicMock(return_value='127.0.0.1')
        return handler

    def test_health_endpoint(self):
        handler = self._make_handler('/health')
        handler.do_GET()
        handler.send_response.assert_called_with(200)

    def test_ready_endpoint(self):
        handler = self._make_handler('/ready')
        handler.do_GET()
        handler.send_response.assert_called_with(200)

    def test_root_endpoint(self):
        handler = self._make_handler('/')
        handler.do_GET()
        handler.send_response.assert_called_with(200)

    def test_not_found(self):
        handler = self._make_handler('/nonexistent')
        handler.do_GET()
        handler.send_response.assert_called_with(404)


if __name__ == '__main__':
    unittest.main()
