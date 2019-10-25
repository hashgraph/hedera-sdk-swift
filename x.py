#!/usr/bin/env python3

# This script is intended to simplify usage inside of
# the docker development environment for Swift SDK

# usage: ./x.py

import shutil
import sys
import subprocess
import os
from os import path

# Useless if there aren't at least 2 arguments
if len(sys.argv) < 2:
    print("USAGE: x.py <operation>")
    print("OPERATIONS: test | build")
    sys.exit(1)

# The #1 argument is always the <operation>
operation = sys.argv[1]

# Validate that this is an allowed operation
OPERATIONS = ['test', 'build']
if operation not in OPERATIONS:
    print(f"target '{target}' not one of 'test' | 'build'")
    sys.exit(0)

# Check if we are inside the Docker environment
if sys.argv[0] != '/opt/x.py':
    # Build the docker environment image
    out = subprocess.run(
        'docker build -q .',
        check=True, shell=True,
        capture_output=True)

    image = out.stdout.decode().strip()

    # Re-run the script from within the docker environment
    pwd = os.getcwd()
    out = subprocess.run(f'docker run --rm -v {pwd}:/workspace {image} {operation}', 
        shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    
    print(out.stdout.decode().strip())

    sys.exit(0)
else:
    if operation == 'test':
        subprocess.run(['swift', 'test'], check=True)
    else:
        subprocess.run(['swift', 'build'], check=True)

    # plugin = path.realpath('vendor/ledger-nanopb/generator/protoc-gen-nanopb')
    # plugin = f'--plugin=protoc-gen-nanopb={plugin}'
    # proto = path.realpath('proto')
    # nanopb = path.realpath('vendor/ledger-nanopb/generator/proto')

    # subprocess.run('make', shell=True, check=True, cwd=nanopb)
    # subprocess.run(
    #     f'protoc {plugin} --nanopb_out=. -I. -I{nanopb} *.proto',
    #     shell=True, check=True,
    #     cwd=proto)

    # # Copy in .c files from ledger-nanopb
    # # Cry
    # shutil.copy("vendor/ledger-nanopb/pb_common.c", "src/")
    # shutil.copy("vendor/ledger-nanopb/pb_decode.c", "src/")
