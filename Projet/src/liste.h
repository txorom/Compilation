#ifndef _liste_
#define _liste_

#include "hachage.h"

struct element{
  struct tab_hach *tab;
  struct element *next;
};

struct element* create_list();
void new_element(struct element *list);
struct element *head(struct element *e);
int add_list(struct element *list, struct expr *e, char *name);
struct expr *find_list(struct element *e, char *name); //return the struct expr named name if it is in the table and NULL else
void delete_head(struct element *e);
void delete_list(struct element *e);


#endif
