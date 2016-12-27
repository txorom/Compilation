#ifndef _liste_
#define _liste_

#include "hachage.h"


struct element{
  struct tab_hach *tab;
  struct element *next;
};

struct list{
  struct element *head;
};

struct list* create_list();
void new_element(struct list *list);
void add_basic_function(struct list *list);
int add_list(struct list *list, struct expr *e, char *name);
struct expr *find_list(struct list *list, char *name); //return the struct expr named name if it is in the table and NULL else
void delete_head(struct list *list);
void delete_list(struct list *list);


#endif
