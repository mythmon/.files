#!/usr/bin/env python
import errno
import logging
import os
import re
import sys
import argparse


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
    logging.debug('Processing {}'.format(source))

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
            logging.warning('Not replacing existing file {} with {}.'.format(dest, source))
            return False
    else:
        logging.info('Linking {} to {}'.format(source, dest))
        if not CONFIG.noop:
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


def clamp(n, bottom, top):
    return min(max(bottom, n), top)


CONFIG = None

def loadConfig():
    global CONFIG
    parser = argparse.ArgumentParser(description='Install dotfiles.')
    parser.add_argument('-n', '--noop', action='store_true')
    parser.add_argument('-v', '--verbose', action='append_const', const=1)
    parser.add_argument('-q', '--quiet', action='append_const', dest='verbose', const=-1)

    opt = parser.parse_args()

    opt.verbose = clamp(2 + sum(opt.verbose or [0]), 0, 4)

    CONFIG = opt


def main():
    loadConfig()

    log_levels = [logging.CRITICAL, logging.ERROR, logging.WARNING, logging.INFO, logging.DEBUG]
    logging.basicConfig(level=log_levels[CONFIG.verbose])

    if CONFIG.noop:
        logging.info('Running in no-op mode')


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
                try:
                    dest = map_file(file_map, root, f)
                    if dest is not None:
                        install_file(os.path.join(root, f), dest)
                except ValueError:
                    logging.error('File "{}" does not match any rules.'.format(f))

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.dirname(__file__)))
    main()
