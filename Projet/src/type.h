#ifndef _TYPE_
#define _TYPE_

#include <stdio.h>

enum type_base{TYPE_INT, TYPE_DOUBLE, TYPE_VOID, TYPE_BOOL, TYPE_UNKNOWN};

struct type{
  int is_function;       //0 is not a function, 1 is a function
  enum type_base tb;     //if is a function, tb is the return type
  int nb_args;            //only if is a function
  struct type **args;   //only if is a function
  int elem_of_tab; //If the variable is an element of a table
  int is_tab; //0 is not a table, 1 is a table
  int nb_elem; //only if is a table
};

struct type *new_type(enum type_base);
char * name_of_type(enum type_base t);
enum type_base type_of_name(char * c);
struct type* cpy_type(struct type *t);
void free_type(struct type*t);

#endif
