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

void add_basic_function(struct list *list){
  struct expr *e = new_expr();
  e->t = new_type(TYPE_VOID);
  e->t->is_function = 1;
  e->t->nb_args = 2;
  e->t->args = malloc(sizeof(enum type_base) * 2);
  e->t->args[0] = TYPE_DOUBLE;
  e->t->args[1] = TYPE_DOUBLE;
  char *name = "createCanvas";
  add_list(list, e, name);
  struct expr *e1 = new_expr();
  e1->t = new_type(TYPE_VOID);
  e1->t->is_function = 1;
  e1->t->nb_args = 1;
  e1->t->args = malloc(sizeof(enum type_base) * 1);
  e1->t->args[0] = TYPE_DOUBLE;
  char *name1 = "background";
  add_list(list, e1, name1);
  struct expr *e2 = new_expr();
  e2->t = new_type(TYPE_VOID);
  e2->t->is_function = 1;
  e2->t->nb_args = 1; 
  e2->t->args = malloc(sizeof(enum type_base) * 1);
  e2->t->args[0] = TYPE_DOUBLE;
  char *name2 = "fill";
  add_list(list, e2, name2);
  struct expr *e3 = new_expr();
  e3->t = new_type(TYPE_VOID);
  e3->t->is_function = 1;
  e3->t->nb_args = 1; 
  e3->t->args = malloc(sizeof(enum type_base) * 1);
  e3->t->args[0] = TYPE_DOUBLE;
  char *name3 = "stroke";
  add_list(list, e3, name3);
  struct expr *e4 = new_expr();
  e4->t = new_type(TYPE_VOID);
  e4->t->is_function = 1;
  e4->t->nb_args = 2; 
  e4->t->args = malloc(sizeof(enum type_base) * 2);
  e4->t->args[0] = TYPE_DOUBLE;
  e4->t->args[1] = TYPE_DOUBLE;
  char *name4 = "point";
  add_list(list, e4, name4);
  struct expr *e5 = new_expr();
  e5->t = new_type(TYPE_VOID);
  e5->t->is_function = 1;
  e5->t->nb_args = 4; 
  e5->t->args = malloc(sizeof(enum type_base) * 4);
  e5->t->args[0] = TYPE_DOUBLE;
  e5->t->args[1] = TYPE_DOUBLE;
  e5->t->args[2] = TYPE_DOUBLE;
  e5->t->args[3] = TYPE_DOUBLE;
  char *name5 = "line";
  add_list(list, e5, name5);
  struct expr *e6 = new_expr();
  e6->t = new_type(TYPE_VOID);
  e6->t->is_function = 1;
  e6->t->nb_args = 4; 
  e6->t->args = malloc(sizeof(enum type_base) * 4);
  e6->t->args[0] = TYPE_DOUBLE;
  e6->t->args[1] = TYPE_DOUBLE;
  e6->t->args[2] = TYPE_DOUBLE;
  e6->t->args[3] = TYPE_DOUBLE;
  char *name6 = "ellipse";
  add_list(list, e6, name6);
  struct expr *e7 = new_expr();
  e7->t = new_type(TYPE_DOUBLE);
  e7->t->is_function = 1;
  e7->t->nb_args = 1; 
  e7->t->args = malloc(sizeof(enum type_base) * 1);
  e7->t->args[0] = TYPE_DOUBLE;
  char *name7 = "log10";
  add_list(list, e7, name7);
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
}
