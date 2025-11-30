#!/home/llegregam/Documents/Projects/tools_w4m/galaxy/.venv/bin/python3

"""
Read a file from stdin, split each line and write fields one per line to
stdout.

TODO: is this really that useful?
"""

import sys

for line in sys.stdin:
    for field in line.split():
        print(field)
