#! /usr/bin/env LD_LIBRARY_PATH=/usr/local/Cellar/llvm/3.4/lib/ python

"""
Lists C/C++ definitions, etc. for files in a directory.

Copyright (C) 2016 Christian Stigen Larsen
Distributed under the LGPL v2.1 or later, or GPL v3 or later.
"""

from clang.cindex import CursorKind as K
import clang.cindex
import multiprocessing
import os
import sys

# CursorKinds to display
_kind_name = {
    K.CALL_EXPR: "call",
    K.CLASS_DECL: "class-decl",
    K.CONSTRUCTOR: "ctor",
    K.CXX_METHOD: "method",
    K.DESTRUCTOR: "dtor",
    K.FUNCTION_DECL: "function-decl",
    K.MEMBER_REF_EXPR: "member-ref",
#    K.PARM_DECL: "param-decl",
    K.USING_DECLARATION: "using-decl",
    K.USING_DIRECTIVE: "using-dir",
    K.VAR_DECL: "var-decl",
}

def check_clang():
    try:
        import clang.cindex as _clang_cindex
        _clang_cindex.Index.create()
    except Exception as e:
        print(e)
        print("")
        print("Try this:\nLD_LIBRARY_PATH=`llvm-config --libdir`")
        sys.exit(1)

def colorize(x):
    return x

def kind_str(kind):
    return _kind_name.get(kind, str(kind))

def known_kind(kind):
    return kind in _kind_name

def read_source(node):
    with open(node.location.file.name, "rt") as f:
        for no, line in enumerate(f.readlines(), 1):
            if no == node.location.line:
                return line.rstrip()

def hilite(loc, ext, name, line):
    if (loc.file is not None and ext.end.file is not None
            and loc.file.name == ext.end.file.name
            and loc.line == ext.end.line):
        s = loc.column - 1
        e = ext.end.column - 1
    else:
        s = loc.column - 1
        e = loc.column - 1 + len(name)

    return line[:s] + colorize(line[s:e]) + line[e:]

def parse(filename, details=False):
    options = 0
    if details:
        # Allows parsing tokens such as comments and so on
        options |= clang.cindex.TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD

    index = clang.cindex.Index.create()
    tu = index.parse(None, [filename], options=options)

    def walk(node):
        fname = "" if node.location.file is None else node.location.file.name
        name = node.spelling if node.spelling is not None else node.displayname
        extract = read_source(node) if node.location.file is not None else ""

        if known_kind(node.kind):
            print("%s:%d:%d:%s:%s:%s" % (
                os.path.relpath(fname),
                node.location.line,
                node.location.column,
                kind_str(node.kind),
                colorize(name),
                hilite(node.location, node.extent, name, extract)))

        for child in node.get_children():
            walk(child)

    walk(tu.cursor)

def iscppfilename(filename):
    suffix = [".cpp", ".c", ".h", ".hpp"]
    return any(map(filename.endswith, suffix))

def main():
    check_clang()
    recursive = True if "-r" in sys.argv[1:] else False

    def find_files(path):
        dirs = []

        for item in os.listdir(path):
            name = os.path.join(path, item)
            if iscppfilename(name):
                yield name
            elif os.path.isdir(name):
                dirs.append(name)

        # breadth-first
        if recursive:
            for item in dirs:
                for child in find_files(item):
                    yield child

    pool = multiprocessing.Pool()
    pool.map(parse, list(find_files(".")))

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
