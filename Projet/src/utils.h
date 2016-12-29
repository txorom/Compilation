#ifndef _UTILS_
#define _UTILS_
#include "type.h"
#include "expr.h"

char *double_to_hex_str(double);
int new_var();
char *new_label();
int list_of_variable(char *src, char **dest);
int list_of_args(char *src, char **dest);
void name_of_function(char *src, char *dest);
void del_carac(char *src, char old);
char * change_file_ll(char *src);
int get_cst_int(char *src);
char* conv_ret(char *src, enum type_base type, char *var);
char* add_function_declaration();
int compare_list(char src1[1024][1024], int taille1, char *src, char dest[1024][1024]);

#endif
