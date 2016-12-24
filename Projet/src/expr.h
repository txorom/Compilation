#ifndef _EXPR_
#define _EXPR_

#include <stdio.h>
#include "type.h"

struct expr{
    char *code;
    int var;
    char *name;
    struct type *t;
};
struct expr * new_expr();

#endif
