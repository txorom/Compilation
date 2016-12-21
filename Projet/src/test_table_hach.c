#include "liste.h"
#include "expr.h"
#include <stdlib.h>

int main(int argc, char const *argv[])
{
	struct element *tab_symbol = create_list();
	struct expr * e= new_expr();
	e->var = 1;
	struct expr * e2= new_expr();
	e2->var = 1;
	add_list(tab_symbol, e, "toto");
	struct expr *e1= find_list(tab_symbol, "tato");
	printf("%p\n", e1);
	new_element(tab_symbol);
	printf("%p %p %p\n", tab_symbol->next, head(tab_symbol), tab_symbol);
	e1= find_list(tab_symbol, "toto");
	add_list(tab_symbol, e2, "tata");
	printf("%d\n", e1->var);
	delete_head(tab_symbol);
	printf("%p %p %p\n", tab_symbol->next, head(tab_symbol), tab_symbol);
	e1= find_list(tab_symbol, "tata");
	printf("%p\n", e1);
	delete_list(tab_symbol);
	printf("%p\n", tab_symbol);
	free(e2);
	free(e);
	return 0;
}