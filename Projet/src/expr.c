#define _GNU_SOURCE
#include <stdlib.h>
#include "expr.h"


struct expr *new_expr(){
	struct expr *e = malloc(sizeof(struct expr));
	e->code = NULL;
	e->name = NULL;
	e->t = NULL;
	e->use = 0;
	e->real = 0;
	return e;
}

struct expr * cpy_expr(struct expr *e){
	struct expr *new = new_expr();
	char *code = NULL, *name = NULL;
	if(e->code != NULL){
		asprintf(&code, "%s", e->code);
	}
	if(e->name != NULL){
		asprintf(&name, "%s", e->name);
	}
	new->var = e->var;
	new->real = e->real;
	new->use = e->use;
	new->real_name = e->real_name;
	new->code = code;
	new->name = name;
	new->t = cpy_type(e->t);
	return new;
}

void free_expr(struct expr **e){
	if((*e)->code != NULL){
		free((*e)->code);
		(*e)->code = NULL;
	}
	if((*e)->name != NULL){
		free((*e)->name);
		(*e)->name = NULL;
	}
	if((*e)->t != NULL){
		free_type((*e)->t);
		(*e)->t = NULL;
	}
	free(*e);
	*e = NULL;
}