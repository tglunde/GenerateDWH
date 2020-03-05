from jinja2 import Environment, FileSystemLoader, select_autoescape
from pprint import pprint
import os
import shutil
from dwhgen.vault import *
from dwhgen.supernova import *
from dwhgen.metadata import *

import argparse


def cli():
    parser = argparse.ArgumentParser()
    parser.add_argument("cmd", help="commmand vault or supernova")
    parser.add_argument(
        "--out", help="output directory path", default="target/")
    parser.add_argument(
        "--tmpl", help="template directory path", default="template/")
    parser.add_argument("--dsn", help="metadata dsn - exasol",
                        default="t020.2150.ch:28020")
    parser.add_argument("--user", help="metadata user - exasol", default="sys")
    parser.add_argument(
        "--password", help="metadata password - exasol", default="")

    args = parser.parse_args()

    if args.cmd == 'vault':
        vault(args.dsn, args.user, args.password, args.out, args.tmpl)

    if args.cmd == 'supernova':
        supernova(args.dsn, args.user, args.password, args.out, args.tmpl)

    if args.cmd == 'metadata':
        metadata(args.tmpl)

if __name__ == '__main__':
    cli()
