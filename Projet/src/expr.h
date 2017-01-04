#ifndef _EXPR_
#define _EXPR_

#include <stdio.h>
#include "type.h"

struct expr{
    char *code;
    int var; //To know the number of the registre
    char *name; //To know the name of the registre
    char *real_name; //To know the name of the variable
    int real; //If it's a real variable or not
    int use; //If the variables is used or not
    struct type *t;
};
struct expr * new_expr();
struct expr * cpy_expr(struct expr *e);
void free_expr(struct expr **e);

#endif
