#include <stdio.h>
#include <stdlib.h>
#include "utils.h"
#include "hachage.h"


struct symbol *new_symbol(char *name, struct expr *ex){
	struct symbol *s = malloc(sizeof(struct symbol));
	s->name = malloc(sizeof(char) * strlen(name));
	strcpy(s->name, name);
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
	if(tab->tab[hach] != NULL){
		return 1;
	}
	tab->tab[hach] = new;
	return 0;
}

struct expr *find_tab(struct tab_hach *tab, char *name){
	int hach = fn_hachage(name);
	if(tab->tab[hach] && strcmp(tab->tab[hach]->name, name) == 0)
		return tab->tab[hach]->e;
	else 
		return NULL;
}

void delete_tab(struct tab_hach *tab){
	for(int i =0; i<SIZE; i++)
		if(tab->tab[i] != NULL){
			if(tab->tab[i]->e->real == 1 && tab->tab[i]->e->use == 0){
				couleur("35");
		      	printf("Attention : ");
		      	couleur("0");
		      	printf("Variable %s inutilisée\n", tab->tab[i]->e->real_name);
			}
			if(tab->tab[i]->e != NULL){
				free_expr(&tab->tab[i]->e);
			}
			free(tab->tab[i]);
		}
	free(tab);
}
