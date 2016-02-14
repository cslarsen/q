#! /usr/bin/env LD_LIBRARY_PATH=/usr/local/Cellar/llvm/3.4/lib/ python

# NOTE: Ugh, set the LD_LIBRARY_PATH above to whatever (or remove it).

"""
Lists C/C++ definitions, etc. for files in a directory.

The point is to easily grep for locations of class definitions, function uses
and so on.

Requires:
    libclang
    ansicolors

Args:
    -r: Optional, recurse into subdirectories.

License:
    Copyright (C) 2016 Christian Stigen Larsen
    Distributed under the LGPL v2.1 or later, or GPL v3 or later.

Examples:

    $ q -r | grep function-decl | grep foo_file
    tests/foo/foo.c:1:5:function-decl:foo_file:int foo_file() {

    $ q -r
    tests/test.cpp:5:7:class-decl:Foo:class Foo; // forward
    tests/test.cpp:6:6:function-decl:foo:void foo(); // forward
    tests/test.cpp:8:7:class-decl:Foo:class Foo {
    tests/test.cpp:10:3:ctor:Foo:  Foo()
    tests/test.cpp:14:3:dtor:~Foo:  ~Foo()
    tests/test.cpp:18:8:method:bar:  void bar() {
    ...
"""

#import colors
from clang.cindex import CursorKind as K
import clang.cindex
import os
import sys

def check_clang():
    try:
        import clang.cindex as _clang_cindex
        _clang_cindex.Index.create()
    except Exception as e:
        print(e)
        print("")
        print("Try this:\nLD_LIBRARY_PATH=`llvm-config --libdir`")
        sys.exit(1)

_color = lambda x: x
#_color = lambda x: colors.bold(colors.red(x))
#_color = colors.bold

_kind_name = {
    K.CLASS_DECL: "class-decl",
    K.CONSTRUCTOR: "ctor",
    K.CXX_METHOD: "method",
    K.DESTRUCTOR: "dtor",
    K.FUNCTION_DECL: "function-decl",
    K.PARM_DECL: "param-decl",
    K.VAR_DECL: "var-decl",
    K.MEMBER_REF_EXPR: "member-ref",
    K.CALL_EXPR: "call",
    K.ENUM_DECL: "enum-decl",
}

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
    e = 999999999999
    if loc.file is not None and loc.file.name == ext.end.file.name:
        if loc.line == ext.end.line:
            s = loc.column-1
            e = ext.end.column-1
            return line[:s] + _color(line[s:e]) + line[e:]

    s = loc.column-1
    e = min(e, loc.column - 1 + len(name))
    return line[:s] + _color(line[s:e]) + line[e:]

def parse(filename):
    options = clang.cindex.TranslationUnit.PARSE_DETAILED_PROCESSING_RECORD
    index = clang.cindex.Index.create()
    tu = index.parse(None, [filename], options=options)

    def grep(node, only_known=True):
        fname = "" if node.location.file is None else node.location.file.name
        name = node.spelling if node.spelling is not None else node.displayname
        extract = read_source(node) if node.location.file is not None else ""

        if not only_known or known_kind(node.kind):
            print("%s:%d:%d:%s:%s:%s" % (
                os.path.relpath(fname),
                node.location.line,
                node.location.column,
                kind_str(node.kind),
                _color(name),
                hilite(node.location, node.extent, name, extract)))

        for child in node.get_children():
            grep(child)

    grep(tu.cursor)

def iscppfilename(filename):
    suffix = [".cpp", ".c", ".h", ".hpp"]
    return any(map(lambda x: filename.endswith(x), suffix))

def main():
    check_clang()

    recursive = True if "-r" in sys.argv[1:] else False

    def parse_dir(path):
        dirs = []
        for item in os.listdir(path):
            name = os.path.join(path, item)
            if iscppfilename(name):
                parse(name)
            elif os.path.isdir(name):
                dirs.append(name)

        # width first
        if recursive:
            for item in dirs:
                parse_dir(item)

    parse_dir(".")

if __name__ == "__main__":
    main()
