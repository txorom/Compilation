#include <stdio.h>
#include <stdlib.h>

#include "liste.h"

struct list* create_list(){
  struct list *new_l = malloc(sizeof(struct list));
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = NULL;
  new_l->head = new_e;
  return new_l;
}

void new_element(struct list *list){
  struct element *new_e = malloc(sizeof(struct element));
  new_e->tab = new_tab();
  new_e->next = list->head;
  list->head = new_e;
}

int add_list(struct list *list, struct expr *e, char *name){
  return add_tab(list->head->tab,e,name);
}

struct expr *find_list(struct list *list, char *name){
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

void delete_head(struct list *list){
  struct element *new_head = list->head->next;
  delete_tab(list->head->tab);
  free(list->head);
  list->head = new_head;
}

void delete_list(struct list *list){
   while(list->head){
    delete_head(list);
   }
   free(list);
<<<<<<< HEAD
=======
   list = NULL;
>>>>>>> f04a4a00f4601aa6b9e43d16b694959891a0dfa7
}
