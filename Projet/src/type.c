#include <stdlib.h>
#include <string.h>
#include "type.h"


struct type *new_type(enum type_base t){
  struct type *ret = malloc(sizeof(struct type));
  ret->is_tab = 0;
  ret->nb_elem = 0;
  ret->elem_of_tab = 0;
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

struct type* cpy_type(struct type *t){
	if(t != NULL){
		struct type *new = new_type(t->tb);
		new->is_function = t->is_function;
		new->nb_args = t->nb_args;
		new->is_tab = t->is_tab;
		new->nb_elem = t->nb_elem;
		new->elem_of_tab = t->elem_of_tab;
		if(new->nb_args){
			new->args = malloc(sizeof(struct type) * new->nb_args);
			for(int i = 0; i < new->nb_args; i++){
				new->args[i] = t->args[i];
			}
		}
		return new;
	}
	return NULL;
}

void free_type(struct type *t){
	if(t->nb_args != 0){
		free(t->args);
	}
	free(t);
}