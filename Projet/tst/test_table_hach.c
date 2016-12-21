#include "../src/liste.h"
#include "../src/expr.h"
#include <assert.h>
#include <stdlib.h>

int main(int argc, char const *argv[])
{
  struct liste *tab_symbol = create_list();
  struct expr * e1= new_expr();
  e1->var = 1;
  struct expr * e2= new_expr();
  e2->var = 2;
  struct expr * e3=new_expr();
  e3->var = 3;
  
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

  struct element *second_tab = tab_symbol->head;
  new_element(tab_symbol);
  assert(second_tab == tab_symbol->head->next);
  assert(frist_tab == tab_symbol->head->next->next);
  
  add_list(tab_symbol, e3, "titi");
  assert(e3 == find_list(tab_symbol, "titi"));
  assert(e2 == find_list(tab_symbol, "tata"));
  assert(e1 == find_list(tab_symbol, "toto"));
  assert(NULL == find_list(tab_symbol, "tati"));

  delete_head(tab_symbol);
  assert(tab_symbol->head == second_tab);
  assert(NULL == find_list(tab_symbol, "titi"));
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
