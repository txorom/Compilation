#include <stdlib.h>
#include "expr.h"


struct expr *new_expr(){
  return malloc(sizeof(struct expr));
}
