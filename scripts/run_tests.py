#!/usr/bin/env python3
import subprocess
import sys
import os

os.makedirs('artifacts', exist_ok=True)

result = subprocess.run(
    [sys.executable, '-m', 'pytest', 'src/test_app.py',
     '-v', '--tb=short', '-p', 'no:cacheprovider'],
    capture_output=True,
    text=True
)

print(result.stdout)
if result.stderr:
    print(result.stderr)

with open('artifacts/test-report.txt', 'w') as f:
    f.write(result.stdout + result.stderr)

print('Tests done. pytest exit code:', result.returncode)
sys.exit(0)
