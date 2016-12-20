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
	return ;
}

struct tab_hach *new_tab(){

}

void add_tab(struct tab_hach *tab, struct expr *e, char *name){

}

int is_in_tab(struct tab_hach *tab, char *name){
	return 0;
}

void delete_tab(struct tab_hach *tab){
	
}