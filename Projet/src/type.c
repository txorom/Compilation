#include <stdlib.h>
#include <string.h>
#include "type.h"


struct type *new_type(enum type_base t){
  struct type *ret = malloc(sizeof(struct type));
  ret->is_function = 0;
  ret->nb_args = 0;
  ret->tb = t;
  ret->args = NULL;
  return ret;
}

char * name_of_type(enum type_base t){
	if(t == TYPE_INT)
		return "i32";
	else if(t == TYPE_DOUBLE)
		return "double";
	else
		return "void";
}

enum type_base type_of_name(char * c){
	int cp = strcmp(c, "i32");
	if(cp == 0)
		return TYPE_INT;
	else if(cp < 0)
		return TYPE_DOUBLE;
	else
		return TYPE_VOID;

}