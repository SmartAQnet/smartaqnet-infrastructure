#!/usr/bin/python
"""
MIT License
Copyright (c) 2019 Till Riedel, Karlsruhe Institute of Technology (KIT)
Copyright (c) 2018 Josh Bode
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import os
import sys
import json

from contextlib import contextmanager

import yaml
import yamlloader

try:
    from pathlib import Path
except ImportError:
    from pathlib2 import Path


@contextmanager
def working_directory(directory):
    """change working directory for includes"""
    owd = os.getcwd()
    try:
        os.chdir(str(directory))
        yield directory
    finally:
        os.chdir(owd)

class Loader(yamlloader.ordereddict.CLoader):
    """YAML Loader with `!include` constructor."""

    def __init__(self, stream):
        """Initialise Loader."""

        try:
            self._root = os.path.split(stream.name)[0]
        except AttributeError:
            self._root = os.path.curdir

        super(Loader, self).__init__(stream)


def construct_include(loader, node):
    """Include file referenced at node."""
    with working_directory(Path(loader._root).resolve()):
        filename = Path(os.path.expandvars(loader.construct_scalar(node))).expanduser().resolve()
    with open(str(filename), 'r') as f:
        if filename.suffix in ('yaml', 'yml'):
            return yaml.load(f, Loader)
        elif filename.suffix in ('json', ):
            return json.load(f)
        else:
            return f.readlines()

def construct_include_raw(loader, node):
    """Include file referenced at node."""
    with working_directory(Path(loader._root).resolve()):
        filename = Path(os.path.expandvars(loader.construct_scalar(node))).expanduser().resolve()
    with open(str(filename), 'r') as f:
        return ''.join(f.readlines())

yaml.add_constructor('!include', construct_include, Loader)
yaml.add_constructor('!include-raw', construct_include_raw, Loader)

if __name__ == '__main__':
    for arg in sys.argv[1:]:
        with open(arg, 'r') as f:
            print(
                yaml.dump(
                    yaml.load(f, Loader),
                    Dumper=yamlloader.ordereddict.CDumper,
                    default_flow_style=False))
    if len(sys.argv) == 1:
        print(yaml.dump(
            yaml.load(sys.stdin, Loader),
            Dumper=yamlloader.ordereddict.CDumper,
default_flow_style=False))
