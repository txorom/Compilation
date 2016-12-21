#ifndef _liste_
#define _liste_

#include "hachage.h"


struct element{
  struct tab_hach *tab;
  struct element *next;
};

struct liste{
  struct element *head;
};

struct liste* create_list();
void new_element(struct liste *list);
int add_list(struct liste *list, struct expr *e, char *name);
struct expr *find_list(struct liste *list, char *name); //return the struct expr named name if it is in the table and NULL else
void delete_head(struct liste *list);
void delete_list(struct liste *list);


#endif
