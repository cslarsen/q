int foo_file() {
  printf("foo file\n");
  return 0;
}

int call_above_function() {
  return 1 + foo_file();
}
