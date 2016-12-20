#ifndef _liste_
#define _liste_

#include "hachage.h"

struct element{
  struct tab_hach *tab;
  struct element *next;
};

void new_liste(struct element *e);
int add_list(struct element *list, struct expr *e, char *name);
struct expr *find_list(struct element *e, char *name); //return the struct expr named name if it is in the table and NULL else
void delete_first_tab(struct element *e);
void delete_liste(struct element *e);

#endif
