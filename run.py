#!/usr/bin/env python

import sys, os, subprocess, shlex
os.environ['PYTHONPATH'] = os.path.join(os.path.abspath(os.path.curdir), '.pylib')
subprocess.Popen(shlex.split('bin/tftpy_server.py -r ../boot'))
