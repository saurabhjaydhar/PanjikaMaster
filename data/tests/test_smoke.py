import sys

import engine


def test_python_version():
    assert sys.version_info >= (3, 12)


def test_engine_package_imports():
    assert engine.__doc__
