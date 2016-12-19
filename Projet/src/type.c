#include <stdlib.h>
#include "type.h"


struct type *new_type(enum type_base t){
  struct type *ret = malloc(sizeof(struct type));
  ret->tb = t;
  return ret;
}
