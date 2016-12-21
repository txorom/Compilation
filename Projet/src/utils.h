#ifndef _UTILS_
#define _UTILS_

char *double_to_hex_str(double);
int new_var();
char *new_label();
int list_of_variable(char *src, char **dest);
void del_carac(char *src, char old);
char * change_file_ll(char *src);
int get_cst_int(char *src);

#endif
