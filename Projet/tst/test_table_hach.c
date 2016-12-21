#include "liste.h"
#include "expr.h"
#include "assert.h"
#include <stdlib.h>

int main(int argc, char const *argv[])
{
  struct liste *tab_symbol = create_list();
  struct expr * e1= new_expr();
  e1->var = 1;
  struct expr * e2= new_expr();
  e2->var = 1;
  
  add_list(tab_symbol, e1, "toto");
  assert(e1 == find_list(tab_symbol, "toto"));
  assert(e1 != find_list(tab_symbol, "tato"));

  struct element *frist_tab = tab_symbol->head;
  new_element(tab_symbol);
  assert(frist_tab != tab_symbol->head);
  assert(frist_tab == tab_symbol->head->next);
  
  add_list(tab_symbol, e2, "tata");
  assert(e2 == find_list(tab_symbol, "tata"));
  assert(e1 == find_list(tab_symbol, "toto"));
  
  delete_head(tab_symbol);
  assert(find_list(tab_symbol,"tata") == NULL);
  assert(e1 == find_list(tab_symbol, "toto"));

  delete_list(tab_symbol);
  free(e2);
  free(e1);
  return 0;
}
