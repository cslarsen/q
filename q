#! /usr/bin/env python

"""
Lists C/C++ definitions, etc. for files in a directory.

Copyright (C) 2016 Christian Stigen Larsen
Distributed under the LGPL v2.1 or later, or GPL v3 or later.
"""

from clang.cindex import CursorKind as K
import clang.cindex
import colors # ansicolors package
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
    K.USING_DECLARATION: "using-decl",
    K.USING_DIRECTIVE: "using-dir",
}

class Options:
    colorize = False

    # Does not follow inclusion nodes
    follow_includes = False

    # Does not print output from files beginning with ".."
    skip_dotted_files = True

    # Search files recursively
    recursive = False

    # From command line
    paths = []

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
    if not Options.colorize:
        return x
    else:
        return colors.bold(colors.magenta(x))

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

def node_filename(node):
    if node.location.file is not None:
        return node.location.file.name
    return None

def parse(filename):
    index = clang.cindex.Index.create()
    tu = index.parse(None, [filename])

    def walk(node):
        # Chase include statements?
        if node.kind == K.INCLUSION_DIRECTIVE:
            if not Options.follow_includes:
                return

        fname = node_filename(node)
        name = node.spelling if node.spelling is not None else node.displayname
        extract = read_source(node) if node.location.file is not None else ""

        if fname is not None and known_kind(node.kind):
            rname = os.path.relpath(fname)
            if not (rname.startswith("..") and Options.skip_dotted_files):
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

def parse_options():
    for arg in sys.argv[1:]:
        if arg.startswith("-"):
            if arg == "-r":
                Options.recursive = True
        else:
            Options.paths.append(arg)

    if Options.recursive and len(Options.paths) == 0:
        Options.paths.append(".")

def find_files():
    def find(path):
        dirs = []

        for item in os.listdir(path):
            name = os.path.join(path, item)
            if iscppfilename(name):
                yield name
            elif os.path.isdir(name) and Options.recursive:
                dirs.append(name)

        # breadth-first
        if Options.recursive:
            for item in dirs:
                for child in find(item):
                    yield child

    # Currently does not work very well (KeyboardInterrupt, hangs with pipes,
    # and so on; lots of stuff to figure out I guess)
    #pool = multiprocessing.Pool()
    #pool.map(parse, find_files("."))

    paths = set()
    for path in Options.paths:
        for p in find(path):
            paths.add(p)

    return paths

def main():
    parse_options()
    check_clang()

    # Currently does not work very well (KeyboardInterrupt, hangs with pipes,
    # and so on; lots of stuff to figure out I guess)
    #pool = multiprocessing.Pool()
    #pool.map(parse, find_files())

    for name in find_files():
        parse(name)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
