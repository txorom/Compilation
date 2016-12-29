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
		asprintf(&dest[nb], "%s", buf);
		nb++;
		dest = realloc(dest, sizeof(char) * (nb + 1));
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
		i = 0;
		src ++;
		while(*src != ' ' && *src != '\n'){
			buf[i] = *src;
			i++;
			src ++;
		}
		buf[i] = '\0';
		dest[nb] = malloc(sizeof(char) * strlen(buf));
		asprintf(&dest[nb], "%s", buf);
		nb++;
		dest = realloc(dest, sizeof(char) * (nb + 1));
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

char* add_function_declaration(){
	char *function;
	char *function1  = "declare void @background(double)\n";
	char *function2 = "declare double @cos(double)\n";
	char *function3 = "declare void @createCanvas(double, double)\n";
	char *function4 = "declare void @ellipse(double, double, double, double)\n";
	char *function5 = "declare void @fill(double)\n";
	char *function6 = "declare double @log10(double)\n";
	char *function7 = "declare void @point(double, double)\n";
	char *function10 = "declare void @rect(double, double, double, double)\n";
	char *function8 = "declare double @sin(double)\n";
	char *function9 = "declare void @stroke(double)\n";
	asprintf(&function, "%s%s%s%s%s%s%s%s%s%s", function1, function2, function3, function4, function5, function6, function7, function10, function8, function9);
	return function;
}

int compare_list(char src1[1024][1024], int taille1, char*src, char dest[1024][1024]){
	int taille = 0;
	char src2[1024][1024];
	int nb = 0;
	int i = 0;
	char buf[1024];
	while(*src != '\0'){
		i = 0;
		src ++;
		while(*src != ' ' && *src != '\n'){
			buf[i] = *src;
			i++;
			src ++;
		}
		buf[i] = '\0';
		strcpy(src2[nb], buf);
		nb++;
		while(*src != '\n'){
			src ++;
		}
		src ++;
	}
	for(int i = 0; i < taille1; i++){
		for(int j = 0; j < nb; j++){
			if(strcmp(src1[i], src2[j]) == 0){
				strcpy(dest[taille], src1[i]);
				taille++;
				strcpy(src1[i], "");
				break;
			}
		}
	}
	return taille;
}

void del_comma(char *src){
	while(*src != '\0'){
		if(*src == ','){
			*src = '\0';
			return;
		}
		src++;

	}
}
char *conv_ret(char *src, enum type_base t, char *var){
	char type1[10], var1[20], var_r[20], store[10], type2[10];
	int nb_conv = 0, length_conv, var_conv, length_old_line = 0;
	int n = strlen(src);
	char *buf = malloc(sizeof(char) * n), *conv, *old_line;
	int i = 0;
	while(*src != '\0'){
		if(*src == 's'){
			if(*(src+1) != '\0' && *(src+1) == 't'){
				if(*(src+2) != '\0' && *(src+2) == 'o'){
					if(*(src+3) != '\0' && *(src+3) == 'r'){
						if(*(src+4) != '\0' && *(src+4) == 'e'){
							printf("ok\n");
							sscanf(src, "%s %s %s %s %s", store, type1, var1, type2, var_r);
							if(strcmp(var_r, var) == 0){
								if(strcmp(type1, name_of_type(t)) != 0){
									del_comma(var1);
									var_conv = new_var();
									if(t == TYPE_INT){
										asprintf(&conv, "%%x%d = fptosi double %s to i32\nstore i32 %%x%d, i32* %s", var_conv, var1, var_conv, var_r);
									}
									else{
										asprintf(&conv, "%%x%d = sitofp i32 %s to double\nstore double %%x%d, double* %s", var_conv, var1, var_conv, var_r);
									}
									asprintf(&old_line, "%s %s %s %s %s", store, type1, var1, type2, var_r);
									printf("%s\n", old_line);
									length_old_line += strlen(old_line);
									length_conv = strlen(conv);
									buf = realloc(buf, sizeof(char) * (n + length_conv));
									asprintf(&buf, "%s%s", buf, conv);
									printf("%s\n", conv);
									i += length_conv;
									src += length_old_line + 1;							
									nb_conv ++;

								}
							}
						}
					}
				}
			}
		}
		buf[i] = *src;
		i++;
		src++;
	}
	asprintf(&src, "%s", buf);
	printf("%s\n", src);
	return buf;
}

