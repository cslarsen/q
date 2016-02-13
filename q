#! /usr/bin/env python2

"""
C/C++ grep tool.
"""

import clang.cindex
import os
import sys

_kinds = [
    "argument",
    "class",
    "function",
    "macro",
    "method",
    "parameter",
    "typedef",
]

_types = [
    "declaration",
    "definition",
    "usage",
]

def parse(filename):
    options = clang.index.TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD
    p = clang.cindex.Index.create()
    r = p.parse(None, args, options=options)
    print(r)

def main():
    kind = sys.argv[1] if len(sys.argv)>1 else None
    files = sys.argv[2] if len(sys.argv)>2 else None

if __name__ == "__main__":
    main()
