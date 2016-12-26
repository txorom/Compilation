#include <stdlib.h>
#include "expr.h"


struct expr *new_expr(){
	return malloc(sizeof(struct expr));
}

struct expr * cpy_expr(struct expr *e){
	struct expr *new = new_expr();
	char *code, *name;
	asprintf(&code, "%s", e->code);
	asprintf(&name, "%s", e->name);
	new->var = e->var;
	new->code = code;
	new->name = name;
	new->t = e->t;
	return new;
}