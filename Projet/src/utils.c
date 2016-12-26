#define _GNU_SOURCE
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
  asprintf(&name, "label%d", i);
  return name;
}

char *double_to_hex_str(double d){
	char *s = NULL;
	union {
		double a;
		long long int b;
	} u;
	u.a = d;
	if(d == 0.0){
		return "0x00000000";
	}
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

int list_of_args(char *src, char **dest){
	int nb = 0;
	int i = 0;
	char buf[1024];
	while(*src != '\0'){
		dest = realloc(dest, sizeof(char) * (nb + 1));
		i = 0;
		src ++;
		while(*src != ' '){
			buf[i] = *src;
			i++;
			src ++;
		}
		buf[i] = '\0';
		dest[nb] = malloc(sizeof(char) * strlen(buf));
		strcpy(dest[nb], buf);
		nb++;
		while(*src != '\n'){
			src ++;
		}
		src ++;
	}
	return nb;
}

void name_of_function(char *src, char *dest){
	int i = 0;
	while(*src != '('){
		dest[i] = *src;
		i++;
		src ++;
	}
	dest[i] = '\0';
}

void del_carac(char *src, char old){
	int flag = 0;
	while(*src != '\0'){
		if(*src == old){
			flag = 1;
		}
		if(flag){
			*src = *(src+1);
		}
		src++;
	}
}

char * change_file_ll(char *src){
	int n = strlen(src);
	char *new = malloc(sizeof(char) * n + 2);
	strcpy(new, src);
	*(new+n-1) = 'l';
	*(new+n) = 'l';
	*(new+n+1) = '\0';
	return new;
}

void replace_last_line(char *src, char *new_line, char *last_line){
	src = realloc(src, sizeof(char) * (strlen(src) + strlen(new_line)));
	int n = strlen(last_line);
	*(src + strlen(src) - n) = '\0';
	strcat(src, new_line);	
}



