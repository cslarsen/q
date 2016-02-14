q: Prints C/C++ definitions, usages, etc.
-----------------------------------------

Prints C/C++ definitions, usages and so on for all files in the current
directory.

The point is to easily grep for class definitions, calls to specific functions,
and so on. For example, to find the declaration of the function `foo_file`,
just do:

    $ q -r | grep function-decl:foo_file
    tests/foo/foo.c:1:5:function-decl:foo_file:int foo_file() {

To find out where this function is called from:

    $ q -r | grep call:foo_file
    tests/foo/foo.c:7:14:call:foo_file:  return 1 + foo_file();

Of course, q doesn't care about namespaces, compilation units or stuff like
that, so it won't discern between multiple `foo_file` functions.

To find calls to either `foo` or `bar`:

    $ q -r | egrep 'call:(foo|bar):'
    tests/test.cpp:40:3:call:foo:  f.foo();
    tests/test.cpp:41:3:call:bar:  f.bar();
    tests/test.cpp:42:3:call:foo:  foo();
    tests/test.cpp:43:3:call:bar:  bar();

For large code bases, you can just dump everything to a cache:

    $ q -r > .qcache
    $ grep call:foo_file .qcache
    tests/foo/foo.c:7:14:call:foo_file:  return 1 + foo_file();

Rationale
---------

I've been looking for a tool like this for some time, but haven't found
anything. (Perhaps I haven't looked hard enough). If you know any, please let
me know!

But if you like this one, let me know as well, and I just might add some spit
and polish.

Requirements
------------

    * libclang for Python
    * pip install ansicolors (well, not strictly used right now)

Note that the hash bang sets `LD_LIBRARY_PATH` to a specific value I use on
*my* machine. I know it's ugly, but this is sooo alpha.

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
