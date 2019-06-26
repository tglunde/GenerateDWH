# -*- coding: utf-8 -*-
#!/usr/bin/env python
from setuptools import find_packages
from distutils.core import setup
import os


this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, 'README.md')) as f:
    long_description = f.read()


package_name = "dwhgen"
package_version = "0.0.1"
description = """With dwhgen users can generate relational dwh including ddl, dml, scheduling and business rule models using DataVault, Airflow and DBT"""


setup(
    name=package_name,
    version=package_version,

    description=description,
    long_description=long_description,
    long_description_content_type='text/markdown',

    author="Torsten Glunde",
    author_email="torsten@glunde.de",
    url="https://bitbucket.org/generatedwhtui/generatedwh/src/master/",

    packages=find_packages(),
    install_requires=[
        'dwhgen-core=={}'.format(package_version),
    ]
)