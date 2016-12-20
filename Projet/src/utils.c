#include <stdio.h>
#include <stdlib.h>
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

char *double_to_hex_str(double d){
	char *s = NULL;
	union {
		double a;
		long long int b;
	} u;
	u.a = d;
	asprintf(&s, "%#08llx", u.b);
	return s;
}