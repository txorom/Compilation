#include <stdio.h>
#include <stdlib.h>

#include "liste.h"

struct liste* create_list(){
  struct liste *new_l = malloc(sizeof(struct liste));
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = NULL;
  new_l->head = new_e;
  return new_l;
}

void new_element(struct liste *list){
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = list->head;
  list->head = new_e;
}

int add_list(struct liste *list, struct expr *e, char *name){
  return add_tab(list->head->tab,e,name);
}

struct expr *find_list(struct liste *list, char *name){
  struct element *current = list->head;
  while(current){
    struct expr *ret = find_tab(current->tab, name);
    if(ret)
      return ret;
    else
      current = current->next;
  }
  return NULL;
}

void delete_head(struct liste *list){
  struct element *new_head = list->head->next;
  delete_tab(list->head->tab);
  free(list->head);
  list->head = new_head;
}

void delete_list(struct liste *list){
   while(list->head){
    delete_head(list);
   }
   free(list);
}
