#include <stdio.h>
#include <stdlib.h>

#include "hachage.h"


struct symbol *new_symbol(char *name, struct expr *ex){
	struct symbol *s = malloc(sizeof(struct symbol));
	s->name = name;
	s->e = ex;
	return s;
}

int fn_hachage(const char *name){
	unsigned int hash = 0; 
	while (*name!='\0') hash = hash*31 + *name++;
	return hash%SIZE;
}

struct tab_hach *new_tab(){
	struct tab_hach *tab = malloc(sizeof(struct tab_hach));
	for(int i =0; i<SIZE; i++)
		tab->tab[i]=NULL;
	return tab;
}

int add_tab(struct tab_hach *tab, struct expr *e, char *name){
	struct symbol *new = new_symbol(name,e);
	int hach = fn_hachage(name);
	if(tab->tab[hach] != NULL)
		return 1;
	tab->tab[hach] = new;
	return 0;
}

struct expr *find_tab(struct tab_hach *tab, char *name){
	int hach = fn_hachage(name);
	if(tab->tab[hach])
		return tab->tab[hach]->e;
	else 
		return NULL;
}

void delete_element(struct tab_hach *tab, char *name){
	int hach = fn_hachage(name);
	free(tab->tab[hach]);
	tab->tab[hach] = NULL;
}

void delete_tab(struct tab_hach *tab){
	for(int i =0; i<SIZE; i++)
		if(tab->tab[i] != NULL)
			free(tab->tab[i]);
	free(tab);
}
