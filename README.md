q: Prints C/C++ definitions, usages, etc.
-----------------------------------------

Prints C/C++ definitions, usages and so on for all files in the current
directory.

The point is to easily grep for class definitions, calls to specific functions,
and so on. For example, to find the definition of the function `foo_file`, just
do:

    $ q -r | grep function-decl:foo_file
    tests/foo/foo.c:1:5:function-decl:foo_file:int foo_file() {

If you want to find out where this function is called from, do:

    $ q -r | grep call:foo_file
    tests/foo/foo.c:7:14:call:foo_file:  return 1 + foo_file();

For large code bases, you can just dump everything to a file and use that:

    $ q -r > .qcache

    $ grep call:foo_file .qcache
    tests/foo/foo.c:7:14:call:foo_file:  return 1 + foo_file();

Rationale
---------

I've been looking for such a tool for some time, but I couldn't find any. So
this is something I've quickly bashed together. If you know any such tools,
please let me know. But if you like this one, let me know as well, and I might
work some more on it.

Requirements
------------

    * libclang for Python
    * pip install ansicolors

Note that the hashbang sets `LD_LIBRARY_PATH` to a specific value I use on my
machine. It's there because I'm the only user as of now. :)

Program arguments
-----------------

  * -r: Optional flag to recurse into subdirectories

License
-------

Copyright (C) 2016 Christian Stigen Larsen  
Distributed under the LGPL v2.1 or later, or GPL v3 or later.

Examples
--------

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
