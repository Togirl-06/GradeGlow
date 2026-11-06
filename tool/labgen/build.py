#!/usr/bin/env python3
"""Validates and generates every lab in tool/labgen/majors, then refreshes the tracker."""
import importlib
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import labgen  # noqa: E402

MODULES = [m[:-3] for m in sorted(os.listdir(os.path.join(HERE, 'majors'))) if m.endswith('.py') and not m.startswith('_')]

if __name__ == '__main__':
    majors = []
    for name in MODULES:
        mod = importlib.import_module(f'majors.{name}')
        majors.append((name, mod.MAJOR))
    try:
        built = labgen.build(majors)
    except labgen.ContentError as e:
        print(f'CONTENT ERROR: {e}')
        sys.exit(1)
    print(f'{len(built)} labs generated from {len(majors)} majors')
    subprocess.run([sys.executable, os.path.join(labgen.ROOT, 'tool/lab_tracker.py')], check=True)
