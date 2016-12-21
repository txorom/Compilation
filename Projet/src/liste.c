#include <stdio.h>
#include <stdlib.h>

#include "liste.h"

struct element* create_list(){
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = NULL;
  return new_e;
}

void new_element(struct element *list){
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = NULL;
  head(list)->next = new_e;
}

struct element *head(struct element *e){
  struct element *current = e;
  while(current->next){
    current = current->next;
  }
  return current;
}

int add_list(struct element *list, struct expr *e, char *name){
  return add_tab(head(list)->tab,e,name);
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

void delete_head(struct element *e){
  struct element *current = e, *prev;
  while(current->next){
    prev = current;
    current = current->next;
  }
  prev->next = NULL;
  delete_tab(current->tab);
  free(current);
  current = NULL;
}

void delete_list(struct element *e){
   while(e->next){
    delete_head(e);
   }
   delete_tab(e->tab);
   free(e);
   e = NULL;
}
