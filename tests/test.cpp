#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

class Foo; // forward
void foo(); // forward

class Foo {
public:
  Foo()
  {
  }

  ~Foo()
  {
  }

  void bar() {
    printf("Foo::bar\n");
  }

  void foo() {
    printf("Foo::foo\n");
  }
};

void foo()
{
  printf("foo\n");
}

void bar()
{
  printf("bar\n");
}

int main(int argc, char** argv)
{
  Foo f;
  f.foo();
  f.bar();
  foo();
  bar();
  return 0;
}
