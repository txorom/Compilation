#ifndef _TYPE_
#define _TYPE_

#include <stdio.h>

enum type_base{INT, DOUBLE, VOID};

struct type{
  int is_function;       //0 is not a function, 1 is a function
  enum type_base tb;     //if is a function, tb is the return type
  int nb_arg;            //only if is a function
  enum type_base *arg;   //only if is a function
};

struct type *new_type(enum type);

#endif
