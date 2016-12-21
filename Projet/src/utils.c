#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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


int list_of_variable(char *src, char **dest){
	int nb = 0;
	char buf[strlen(src) + 1];
	int i = 0;
	while(*src != '\0'){
		i = 0;
		while(*src != ' ' && *src != '\0'){
			buf[i] = *src;
			i++;
			src ++;
		}
		buf[i] = '\0';
		dest[nb] = malloc(sizeof(char) * strlen(buf));
		strcpy(dest[nb], buf);
		nb++;
		if(*src != '\0')
			src++;
	}
	return nb;
}


