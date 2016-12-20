#ifndef _liste_
#define _liste_

#include "hachage.h"

struct element{
  struct tab_hach *tab;
  struct element *next;
};

void new_tab_in_liste(struct element *e); // create a new symbol tab in the list (use at the beginning of a block)
int add_list(struct element *list, struct expr *e, char *name); //add a new symbol in the symbol tab.
void delete_first_tab(struct element *e); //delete the current symbol tab (use at the end of a block)
void delete_liste(struct element *e); //delete all the symbol tabs (for use at the end)

#endif
