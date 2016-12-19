#include "utils.h"


int new_var(){
  static int i=0;
  return i++;
}

char* new_label(){
  static int i=0;
  i++;
  char *name;
  asprintf(&name, "label%d :", i);
  return name;
}
