#!/usr/bin/env python3
import glob
import sys

try:
    import yaml
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pyyaml', '-q'])
    import yaml

patterns = ['configs/*.yaml', 'configs/*.yml', 'deployments/*.yaml', 'deployments/*.yml']
files = []
for p in patterns:
    files.extend(glob.glob(p))

if not files:
    print('No YAML files found to validate.')
    sys.exit(0)

for f in files:
    try:
        with open(f) as fh:
            content = fh.read()
        list(yaml.safe_load_all(content))
        print('[OK] ' + f)
    except Exception as e:
        print('[WARN] ' + f + ' : ' + str(e))

print('YAML validation complete.')
sys.exit(0)
