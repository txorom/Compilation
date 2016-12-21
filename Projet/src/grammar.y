%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "expr.h"
    #include "type.h"
    #include "utils.h"
    #include "liste.h"
    #define couleur(param) printf("\033[%sm",param)
    extern int yylineno;
    int yylex ();
    int yyerror ();
    struct element *tab_symbol;
%}

%token <string> IDENTIFIER
%token <i> CONSTANTI
%token <d> CONSTANTD
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN DIV_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN
%token REM_ASSIGN
%token REM SHL SHR
%token AND OR
%token TYPE_NAME
%token INT DOUBLE VOID
%token IF ELSE DO WHILE RETURN FOR
%type <e> conditional_expression logical_or_expression logical_and_expression shift_expression primary_expression postfix_expression argument_expression_list unary_expression
unary_operator multiplicative_expression additive_expression comparison_expression expression assignment_operator declaration declarator_list type_name declarator parameter_list parameter_declaration statement compound_statement declaration_list statement_list expression_statement selection_statement iteration_statement jump_statement program external_declaration function_definition
%start program
%union {
  char *string;
  int i;
  double d;
  struct expr* e;
}
%%

conditional_expression
: logical_or_expression {$$ = new_expr();
                         char *code;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;
                        }
;

logical_or_expression
: logical_and_expression {$$ = new_expr();
                          char *code;
                          asprintf(&code, "%s", $1->code);
                          $$->code = code;
                          $$->t = new_type(TYPE_INT);
                         }
| logical_or_expression OR logical_and_expression {}
;

logical_and_expression
: comparison_expression {$$ = new_expr();
                         char *code;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;
                        }
| logical_and_expression AND comparison_expression {}
;


shift_expression
: additive_expression {$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;
                      }
| shift_expression SHL additive_expression {}
| shift_expression SHR additive_expression {}
;

primary_expression
: IDENTIFIER {struct expr *e = find_list(tab_symbol, $1);
              if(e == NULL){
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" inconnue à la ligne %d\n", $1, yylineno);
                return 1;
              }
              $$ = e;
              char *code;
              asprintf(&code, "%s* %%%s", name_of_type(e->t->tb),$1);
              $$->code = code;
             }
| CONSTANTI {
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_INT);
              char *code;
              char *nom;
              asprintf(&nom, "%%x%d", $$->var);
              asprintf(&code, "%%x%d = add i32 0, %d \n",$$->var, $1);
              add_list(tab_symbol, $$, nom);
              $$->code = code;
            }
| CONSTANTD {
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_DOUBLE);
              char *code;
              char *nom;
              asprintf(&nom, "%%x%d", $$->var);
              asprintf(&code, "%%x%d = fadd double %s, %s \n",$$->var, double_to_hex_str(0.0), double_to_hex_str($1));
              add_list(tab_symbol, $$, nom);
              $$->code = code;
            }
| '(' expression ')' {}
| IDENTIFIER '(' ')' {}
| IDENTIFIER '(' argument_expression_list ')' {}
;

postfix_expression
: primary_expression {$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;
                     }
| postfix_expression INC_OP {}
| postfix_expression DEC_OP {}
;

argument_expression_list
: expression {}
| argument_expression_list ',' expression {}
;

unary_expression
: postfix_expression {$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;
                     }
| INC_OP unary_expression {}
| DEC_OP unary_expression {}
| unary_operator unary_expression {}
;

unary_operator
: '-' {}
;

multiplicative_expression
: unary_expression {$$ = new_expr();
                    char *code;
                    asprintf(&code, "%s", $1->code);
                    printf("a : %s\n", code);
                    $$->code = code;
                   }
| multiplicative_expression '*' unary_expression {}
| multiplicative_expression '/' unary_expression {}
| multiplicative_expression REM unary_expression {}
;

additive_expression
: multiplicative_expression {$$ = new_expr();
                             char *code;
                             asprintf(&code, "%s", $1->code);
                             $$->code = code;
                            }
| additive_expression '+' multiplicative_expression {$$ = new_expr();
                                                     printf("1 : %s %s\n", $1->code, $3->code);
                                                    }
| additive_expression '-' multiplicative_expression {}
;

comparison_expression
: shift_expression {$$ = new_expr();
                    char *code;
                    asprintf(&code, "%s", $1->code);
                    $$->code = code;
                   }
| comparison_expression '<' shift_expression {}
| comparison_expression '>' shift_expression {}
| comparison_expression LE_OP shift_expression {}
| comparison_expression GE_OP shift_expression {}
| comparison_expression EQ_OP shift_expression {}
| comparison_expression NE_OP shift_expression {}
;

expression
: unary_expression assignment_operator conditional_expression 
{printf("ok\n");$$ = new_expr();
char *code;
char * nom0;
asprintf(&nom0, "%%x%d", $3->var);
struct expr *cst0 = find_list(tab_symbol, nom0);
asprintf(&code, "%s%s %%x%d %s, %s\n", $3->code, $2->code, $3->var, name_of_type(cst0->t->tb), $1->code);
$$->code = code;
}
| conditional_expression {}
;

assignment_operator
: '=' {$$ = new_expr();
       char *code;
       asprintf(&code, "store");
       $$->code = code;
       }
| MUL_ASSIGN {}
| DIV_ASSIGN {}
| REM_ASSIGN {}
| SHL_ASSIGN {}
| SHR_ASSIGN {}
| ADD_ASSIGN {}
| SUB_ASSIGN {}
;

declaration
: type_name declarator_list ';' {$$ = new_expr();
                                 char code[1024] = "";
                                 char *list;
                                 struct expr *e;
                                 char *tab[strlen($2->code)];
                                 int nb_var = list_of_variable($2->code, tab);
                                 for(int i = 0; i < nb_var; i++){
                                    asprintf(&list, "%%%s = alloca %s\n", tab[i], $1->code);
                                    e = find_list(tab_symbol, tab[i]);
                                    e->t = new_type(type_of_name($1->code));
                                    strcat(code, list);
                                 }
                                 $$->code = code;
                                 }
;

declarator_list
: declarator {$$ = new_expr();
              char *code;
              asprintf(&code, "%s", $1->code);
              $$->code = code;
             }
| declarator_list ',' declarator {$$ = new_expr();
              char *code;
              asprintf(&code, "%s %s", $1->code, $3->code);
              $$->code = code;}
;

type_name
: VOID {$$ = new_expr();
       $$->t = new_type(TYPE_VOID);
       char *code;
       asprintf(&code, "void");
       $$->code = code;
       }
| INT {$$ = new_expr();
       $$->t = new_type(TYPE_INT);
       char *code;
       asprintf(&code, "i32");
       $$->code = code;
      }
| DOUBLE {$$ = new_expr();
          $$->t = new_type(TYPE_DOUBLE);
          char *code;
          asprintf(&code, "double");
          $$->code = code;
         }
;

declarator
: IDENTIFIER {if(find_list(tab_symbol, $1) != NULL){
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" redéfinie à la ligne %d\n", $1, yylineno);
                return 1;
              }
              $$ = new_expr();
              char *code;
              asprintf(&code, "%s",$1);
              $$->code = code;
              add_list(tab_symbol, new_expr(), $1);
              } //ajouter dans la table de hachage(table des symboles) le nom de la variable $1 (=IDENTIFIER)
| '(' declarator ')' {}
| declarator '(' parameter_list ')' {}
| declarator '(' ')' {$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s()", $1->code);
                      $$->code = code;
                     }
;

parameter_list
: parameter_declaration {}
| parameter_list ',' parameter_declaration {}
;

parameter_declaration
: type_name declarator {}
;

statement
: compound_statement {$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;
                     }
| expression_statement {$$ = new_expr();
                        char *code;
                        asprintf(&code, "%s", $1->code);
                        $$->code = code;
                       }
| selection_statement {$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;
                      }
| iteration_statement {$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;
                      }
| jump_statement {$$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;
                 }
;

compound_statement
: '{' '}' {new_element(tab_symbol);
           delete_head(tab_symbol);
          }
| '{' statement_list '}' {new_element(tab_symbol);

                          delete_head(tab_symbol);
                          }
| '{' declaration_list statement_list '}' {new_element(tab_symbol);
                                           $$ = new_expr();
                                           char *code;
                                           asprintf(&code, "{\n%s%s\n}", $2->code, $3->code);
                                           $$->code = code; 
                                           delete_head(tab_symbol);
                                          }
| '{' declaration_list '}' {new_element(tab_symbol);
                            $$ = new_expr();
                            char *code;
                            asprintf(&code, "{\n%s\n}", $2->code);
                            $$->code = code;
                            delete_head(tab_symbol);
                           }
;

declaration_list
: declaration {$$ = new_expr();
               char *code;
               asprintf(&code, "%s", $1->code);
               $$->code = code;
              }
| declaration_list declaration {$$ = new_expr();
                                char *code;
                                asprintf(&code, "%s%s", $1->code, $2->code);
                                $$->code = code;
                               }
;

statement_list
: statement {$$ = new_expr();
             char *code;
             asprintf(&code, "%s", $1->code);
             $$->code = code;
            }
| statement_list statement {$$ = new_expr();
                            char *code;
                            asprintf(&code, "%s%s", $1->code, $2->code);
                            $$->code = code;
                           }
;

expression_statement
: ';' {}
| expression ';' {$$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;
                 }
;

selection_statement
: IF '(' expression ')' statement {}
| IF '(' expression ')' statement ELSE statement {}
| FOR '(' expression ';' expression ';' expression ')' statement {}
| FOR '(' expression ';' expression ';'            ')' statement {}
| FOR '(' expression ';'            ';' expression ')' statement {}
| FOR '(' expression ';'            ';'            ')' statement {}
| FOR '('            ';' expression ';' expression ')' statement {}
| FOR '('            ';' expression ';'            ')' statement {}
| FOR '('            ';'            ';' expression ')' statement {}
| FOR '('            ';'            ';'            ')' statement {}
;

iteration_statement
: WHILE '(' expression ')' statement {}
| DO statement WHILE '(' expression ')' {}
;

jump_statement
: RETURN ';' {}
| RETURN expression ';' {}
;

program
: external_declaration 
| program external_declaration 
;

external_declaration
: function_definition
| declaration {}
;

function_definition
: type_name declarator compound_statement {$$ = new_expr();
                                           char *code;
                                           asprintf(&code, "define %s @%s %s", $1->code, $2->code, $3->code);
                                           $$->code = code;
                                           printf("code : %s\n", $$->code);
                                          }
;

%%
#include <stdio.h>
#include <string.h>

extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
    return 0;
}


int main (int argc, char *argv[]) {
  tab_symbol = create_list();
  FILE *input = NULL;
  if (argc==2) {
	input = fopen (argv[1], "r");
	file_name = strdup (argv[1]);
	if (input) {
	    yyin = input;
	}
	else {
	  fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
	    return 1;
	}
    }
    else {
	fprintf (stderr, "%s: error: no input file\n", *argv);
	return 1;
    }
    yyparse ();
    free (file_name);
    delete_list(tab_symbol);
    return 0;
}
