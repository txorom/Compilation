#ifndef _UTILS_
#define _UTILS_

char *double_to_hex_str(double);
int new_var();
char *new_label();
int list_of_variable(char *src, char **dest);
int list_of_args(char *src, char **dest);
void name_of_function(char *src, char *dest);
void del_carac(char *src, char old);
char * change_file_ll(char *src);
int get_cst_int(char *src);
void replace_last_line(char *src, char *new_line, char *last_line);

#endif
