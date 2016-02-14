q: Prints C/C++ definitions, usages, etc.
-----------------------------------------

Prints C/C++ definitions, etc. for files in a directory.

The point is to easily grep for locations of class definitions, function uses
and so on.

Requirements
------------

    libclang
    pip install ansicolors

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
