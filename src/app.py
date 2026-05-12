#!/usr/bin/env python3
"""
DevOps CI/CD Security Platform - Sample Application
Demonstrates secure coding practices.
"""

import os
import json
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

PORT = int(os.environ.get('PORT', 8080))
VERSION = os.environ.get('APP_VERSION', '1.0.0')


class AppHandler(BaseHTTPRequestHandler):
    """Secure HTTP request handler."""

    def do_GET(self):
        if self.path == '/health':
            self._send_json(200, {'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})
        elif self.path == '/ready':
            self._send_json(200, {'status': 'ready', 'version': VERSION})
        elif self.path == '/':
            self._send_json(200, {
                'app': 'DevOps CI/CD Security Platform',
                'version': VERSION,
                'endpoints': ['/health', '/ready']
            })
        else:
            self._send_json(404, {'error': 'Not found'})

    def _send_json(self, status_code: int, data: dict):
        body = json.dumps(data).encode('utf-8')
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        logger.info(f"{self.address_string()} - {format % args}")


def main():
    logger.info(f"Starting DevOps App v{VERSION} on port {PORT}")
    server = HTTPServer(('0.0.0.0', PORT), AppHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Server shutting down.")
        server.server_close()


if __name__ == '__main__':
    main()
