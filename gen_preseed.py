#!/usr/bin/env python
import os
import sys
import glob
import argparse
import random
import pystache
from passlib.hash import sha512_crypt


def generate_preseed(rootpw, fullname, username, userpw):
    renderer = pystache.Renderer(file_encoding='utf-8',
                                 search_dirs=os.path.abspath('tmpl'),
                                 string_encoding='utf-8')
    for i in glob.glob('tmpl/*.mustache'):
        filename = os.path.basename(i).split('.mustache')[0]
        tmpl = renderer.load_template(filename)
        data = renderer.render(tmpl, dict(rootpw=rootpw,
                                          fullname=fullname,
                                          username=username,
                                          userpw=userpw))
        with open('public/{0}'.format(filename), 'w') as fobj:
            fobj.write(data)


def generate_passwd(password):
    salt_set = ('abcdefghijklmnopqrstuvwxyz'
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                '0123456789./')
    salt = ''.join([random.choice(salt_set) for c in 16 * ' '])
    return sha512_crypt.encrypt(password, salt=salt)


def parse_options():
    prs = argparse.ArgumentParser()
    prs.add_argument('-r', '--rootpw', action='store', required=True)
    prs.add_argument('-f', '--fullname', action='store', required=True)
    prs.add_argument('-u', '--username', action='store', required=True)
    prs.add_argument('-p', '--userpw', action='store', required=True)
    return prs.parse_args()


def main():
    args = parse_options()
    generate_preseed(generate_passwd(args.rootpw),
                     args.fullname,
                     args.username,
                     generate_passwd(args.userpw))


if __name__ == '__main__':
    main()
