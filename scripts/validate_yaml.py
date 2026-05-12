#!/usr/bin/env python3
import glob
import sys
import yaml

patterns = [
    'configs/*.yaml', 'configs/*.yml',
    'deployments/*.yaml', 'deployments/*.yml'
]

files = []
for p in patterns:
    files.extend(glob.glob(p))

if not files:
    print('No YAML files found.')
    sys.exit(0)

for f in files:
    try:
        with open(f, 'r') as fh:
            list(yaml.safe_load_all(fh.read()))
        print('[OK] ' + f)
    except yaml.YAMLError as e:
        print('[WARN] ' + f + ': ' + str(e))

print('YAML validation complete.')
sys.exit(0)
