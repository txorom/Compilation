#include <stdlib.h>
#include "expr.h"


struct expr *new_expr(){
	struct expr *e = malloc(sizeof(struct expr));
	e->name = NULL;
	e->t = NULL;
	return e;
}

struct expr * cpy_expr(struct expr *e){
	struct expr *new = new_expr();
	char *code, *name = NULL;
	asprintf(&code, "%s", e->code);
	if(e->name != NULL){
		asprintf(&name, "%s", e->name);
	}
	new->var = e->var;
	new->code = code;
	new->name = name;
	new->t = e->t;
	return new;
}