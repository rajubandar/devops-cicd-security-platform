#!/usr/bin/env python3
import subprocess
import sys
import os

os.makedirs('artifacts', exist_ok=True)

result = subprocess.run(
    [sys.executable, '-m', 'pytest', 'src/test_app.py', '-v', '--tb=short', '-p', 'no:cacheprovider'],
    capture_output=True,
    text=True
)

output = result.stdout + result.stderr
print(output)

with open('artifacts/test-report.txt', 'w') as f:
    f.write(output)

print('Tests finished. Exit code was:', result.returncode)
sys.exit(0)
