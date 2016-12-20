#ifndef _HACHAGE_
#define _HACHAGE_

#include <string.h>

#include "expr.h"

#define SIZE 1013

struct symbol{
	char *name;
	struct expr *e;
};

struct symbol *new_symbol(char *name, struct expr *ex);

struct tab_hach{
	struct symbol *tab[SIZE];
};

int fn_hachage(const char *name);

struct tab_hach *new_tab();
int add_tab(struct tab_hach *tab, struct expr *e, char *name); //0 in success, 1 in faillure
struct expr *is_in_tab(struct tab_hach *tab, char *name) //return the struct expr named name if it is in the table and NULL else
void delete_tab(struct tab_hach *tab);


#endif