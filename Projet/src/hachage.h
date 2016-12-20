#ifndef _HACHAGE_
#define _HACHAGE_

#include "expr.h"
#define SIZE 1013

struct symbol{
	char *nom;
	struct expr *e;
};

struct symbol new_symbol(char *nom, struct expr *e);

struct element{
	struct symbol *t;
	struct element *next;
};

struct element DERNIER ={NULL,NULL};

void ajout_element(struct element *first, struct symbol *sym);
int est_dans_list(struct element *first, char *nom);
void suppr_list(struct element *first, char *nom);
void delete_list(struct element *first);

struct tab_hach{
	struct element *tab[SIZE];
};

int fn_hachage(struct type t);

struct tab_hach *new_tab();
void ajout_tab(struct tab_hach *tab, struct expr *e, char *nom);
int est_dans_tab(struct tab_hach *tab, char *nom)
void supprime_tab(struct tab_hach *tab);


#endif