#include <stdio.h>
#include <stdlib.h>

#include "liste.h"

void new_tab_in_liste(struct element *e){
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = e;
  e = new_e;
}

int add_list(struct element *list, struct expr *e, char *name){
  return add_tab(list->tab,e,name);
}

struct expr *find_list(struct element *e, char *name){
  struct element *current = e;
  while(current){
    struct expr *ret = find_tab(current->tab, name);
    if(ret)
      return ret;
    else
      current = current->next;
  }
  return NULL;
}

void delete_first_tab(struct element *e){
  delete_tab(e->tab);
  struct element *ret = e->next;
  free(e);
  e = ret;
}

void delete_liste(struct element *e){
  while(e) delete_first_tab(e);
}
