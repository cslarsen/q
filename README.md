Update: Use gtags instead :-)
-----------------------------

This looked nice at the beginning, but was way to slow for large projects.
And, anyway, there's gtags, which looks really great. So this project is dead
and only left here for posterity.

I'm not a fan of ctags (probably because I don't know much about it yet), but
gtags seems pretty neat!

But here's a quick guide on using gtags.

Building gtags on Redhat
------------------------

Got a linker error. You need to link with libtinfo:

    $ tar xf global*
    $ cd global-*
    $ LIBS=-ltinfo ./configure --prefix=...
    $ make -j check
    $ make -j install

Creating and using gtags
------------------------

Now, to create tags for a large project:

    $ cd proj/
    $ gtags

To locate functions:

    $ global -x func
    ...

Reindexing with git
-------------------

See
http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html

And use gtags instead of ctags. Then all your git operations (checkout, pull,
rebase, etc) will reindex in the background.

You can probably do this cleverly, but to get started, this is what I did. I
added `hooks/gtags`:

    #! /bin/sh
    set -e
    dir="`git rev-parse --git-dir`"
    cd $dir/..
    if [ ! -f GTAGS ]; then
      gtags
    fi
    global -u

It basically places `GTAGS` etc in your project root. You probably want to
place the GTAGS files elsewhere and then move them over when they're finished,
so that `global` won't attempt to use a half-finished gtags file (since it's
run int he background; see below).

Also, you can probably do `gtags --single-update filename` as in the original
script with `git ls`, which will be faster.

The `hooks/post-rewrite` does this:

    #! /bin/sh
    case "$1" in
      rebase) exec .git/hooks/post-merge ;;
    esac

And `post-merge`, `post-commit` and `post-checkout` do:

    #! /bin/sh
    .git/hooks/gtags >/dev/null 2>&1 &

Seems to work nicely, except that many of our `.h` files are actually C++, so I
need to figure out how to get gtags to parse them as such (`gtags -e` indicates
that they are parsed as C files).

More command line usage
-----------------------

To *grep* for something, do

    $ global -g pattern

I've added an alias that displays some details:

    $ alias gg='global -x'

So now I can do:

    $ gg foobar # exact search
    $ gg -g foobar # grep-like search

In vim
------

You can also use gtags.vim for vim. To do that:

    $ vim
    :source .../gtags.vim

Now you can do

    :Gtags func

OLD: q: Prints C/C++ definitions, usages, etc.
==============================================

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

Of course, q doesn't care about stuff like namespaces, compilation units and so
on, and thus won't discern between multiple `foo_file` functions.

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
me know! (Or let me know how ctags actually works)

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

Public domain

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
