#!/usr/bin/env python
import errno
import logging
import os
import re
import sys


logging.basicConfig(level=logging.DEBUG)


def parse_map(map_str):
    file_map = []
    for line in map_str.split('\n'):
        if not line:
            continue

        find, replace = line.split(' -- ', 1)
        file_map.append((find, replace))
    return file_map


def map_file(file_map, d, f):
    for find, repl in file_map:
        if '/' in find:
            source = os.path.join(d, f)
            includes_path = True
        else:
            source = f
            includes_path = False

        match = re.match(find, source)

        if match:
            if repl == '!ignore':
                return None
            ret = re.sub(find, repl, source)

            if includes_path:
                return ret
            else:
                return os.path.join(d, ret)
    else:
        raise ValueError('File {} does not match any rules.'.format(f))


def install_file(source, dest):
    dest = os.path.expanduser(dest)

    try:
        dirname = os.path.dirname(dest)
        if dirname:
            os.makedirs(dirname)
    except OSError as e:
        # Error 'File Exists' is ok, all others are a problem.
        if e.errno != errno.EEXIST:
            raise

    if os.path.exists(dest):
        if os.path.samefile(source, dest):
            return True
        else:
            print 'Not replacing existing file {} with {}.'.format(dest, source)
            return False
    else:
        print 'Linking {} to {}'.format(source, dest)
        os.link(source, dest)


class ChangeDir(object):
    def __init__(self, path):
        self.path = path
        self.olddir = os.path.curdir

    def __enter__(self):
        self.olddir = os.path.curdir
        os.chdir(self.path)

    def __exit__(self, *args):
        os.chdir(self.olddir)


def main():
    try:
        with open('map') as f:
            map_str = f.read()
    except IOError:
        logging.error('Could not open map file.')
        sys.exit(1)

    file_map = parse_map(map_str)

    with ChangeDir('configs'):
        for root, dirs, files in os.walk('.'):
            # Remove leading ./ or .
            root = re.sub(r'^./?', '', root)
            for f in files:
                dest = map_file(file_map, root, f)
                if dest is not None:
                    install_file(os.path.join(root, f), dest)

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.dirname(__file__)))
    main()
