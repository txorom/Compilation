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
    struct list *tab_symbol;
    char *CODE;
    int error = 0;
    int create = 1;
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
unary_operator multiplicative_expression additive_expression comparison_expression expression assignment_operator declaration declarator_list type_name declarator parameter_list parameter_declaration statement compound_statement declaration_list statement_list expression_statement selection_statement iteration_statement jump_statement main program external_declaration function_definition
%start main
%union {
  char *string;
  int i;
  double d;
  struct expr* e;
}
%%

conditional_expression
: logical_or_expression {printf("conditional_expression -> logical_or_expression \n");
                         $$ = $1;
                         /*$$ = new_expr();
                         char *code;
                         $$->var = $1->var;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;*/
                        }
;

logical_or_expression
: logical_and_expression {printf("logical_or_expression -> logical_and_expression \n");
                          $$ = new_expr();
                          char *code;
                          $$->var = $1->var;
                          asprintf(&code, "%s", $1->code);
                          $$->code = code;
                          $$->t = new_type(TYPE_INT);
                         }
| logical_or_expression OR logical_and_expression {printf("logical_or_expression -> logical_or_expression OR logical_and_expression \n");}
;

logical_and_expression
: comparison_expression {printf("logical_and_expression -> comparison_expression \n");
                         $$ = $1;
                         /*$$ = new_expr();
                         char *code;
                         $$->var = $1->var;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;*/
                        }
| logical_and_expression AND comparison_expression {printf("logical_and_expression -> logical_and_expression AND comparison_expression\n");}
;


shift_expression
: additive_expression {printf("shift_expression -> additive_expression \n");
                       $$ = $1;
                       /*$$ = new_expr();
                       char *code;
                       $$->var = $1->var;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| shift_expression SHL additive_expression {printf("shift_expression -> shift_expression SHL additive_expression \n");}
| shift_expression SHR additive_expression {printf("shift_expression -> shift_expression SHR additive_expression \n");}
;

primary_expression
: IDENTIFIER {printf("primary_expression -> IDENTIFIER (%s)\n", $1);
              struct expr *e = find_list(tab_symbol, $1);
              if(e == NULL){
                error ++;
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" inconnue à la ligne %d\n", $1, yylineno);
                return 1;
              }
              $$ = new_expr();
	      $$->var = new_var();
	      $$->t = e->t;
	      char *code;
	      asprintf(&code, "%%x%d = load %s, %s* %%%s\n", $$->var, name_of_type($$->t->tb), name_of_type($$->t->tb), $1);
	      $$->code = code;
              }
| CONSTANTI {printf("primary_expression -> CONSTANTI (%d)\n", $1);
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_INT);
              char *code;
              asprintf(&code, "%%x%d = add i32 0, %d \n",$$->var, $1);
              $$->code = code;
            }
| CONSTANTD {printf("primary_expression -> CONSTANTD (%f)\n", $1);
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_DOUBLE);
              char *code;
              asprintf(&code, "%%x%d = fadd double %s, %s \n",$$->var, double_to_hex_str(0.0), double_to_hex_str($1));
              $$->code = code;
            }
| '(' expression ')' {printf("primary_expression -> '(' expression ')' \n");}
| IDENTIFIER '(' ')' {printf("primary_expression -> IDENTIFIER '(' ')' \n");}
| IDENTIFIER '(' argument_expression_list ')' {printf("primary_expression -> IDENTIFIER '(' argument_expression_list ')' \n");}
;

postfix_expression
: primary_expression {printf("postfix_expression -> primary_expression \n");
   $$ = $1;
   /*$$ = new_expr();
                      $$->t = new_type($1->t->tb);
                      $$->var = $1->var;
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
                     }
| postfix_expression INC_OP {printf("postfix_expression -> postfix_expression INC_OP \n");}
| postfix_expression DEC_OP {printf("postfix_expression -> postfix_expression DEC_OP \n");}
;

argument_expression_list
: expression {printf("argument_expression_list -> expression \n");}
| argument_expression_list ',' expression {printf("argument_expression_list -> argument_expression_list ',' expression \n");}
;

unary_expression
: postfix_expression {printf("unary_expression -> postfix_expression \n");
                      $$ = $1;
                      /*$$ = new_expr();
                      $$->t = new_type($1->t->tb);
                      $$->var = $1->var;
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
                     }
| INC_OP unary_expression {printf("unary_expression -> INC_OP unary_expression  \n");}
| DEC_OP unary_expression {printf("unary_expression -> DEC_OP unary_expression  \n");}
| unary_operator unary_expression {printf("unary_expression -> unary_operator unary_expression \n");}
;

unary_operator
: '-' {printf("unary_operator -> '-' \n");}
;

multiplicative_expression
: unary_expression {printf("multiplicative_expression -> unary_expression  \n");
                    $$ = $1;
                    /*$$ = new_expr();
                    $$->t = new_type($1->t->tb);
                    $$->var = $1->var;
                    char *code;
                    asprintf(&code, "%s", $1->code);
                    $$->code = code;*/
                   }
| multiplicative_expression '*' unary_expression {printf("multiplicative_expression -> multiplicative_expression '*' unary_expression  \n");}
| multiplicative_expression '/' unary_expression {printf("multiplicative_expression -> multiplicative_expression '/' unary_expression \n");}
| multiplicative_expression REM unary_expression {printf("multiplicative_expression -> multiplicative_expression REM unary_expression  \n");}
;

additive_expression
: multiplicative_expression {printf("additive_expression -> multiplicative_expression \n");
                             $$ = $1;
			       /*$$ = new_expr();
                             $$->t = new_type($1->t->tb);
                             $$->var = $1->var;
                             char *code;
                             asprintf(&code, "%s", $1->code);
                             $$->code = code;*/
                            }
| additive_expression '+' multiplicative_expression {printf("additive_expression ->  additive_expression '+' multiplicative_expression \n");
                                                     $$ = new_expr();
                                                     $$->t = new_type($1->t->tb);

                                                     $$->var = new_var();
						     char *code;
						     asprintf(&code, "%s%s%%x%d = add %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
						     $$->code = code;
						     /*
						     
                                                     char *code1;
                                                     int var1, var2;
                                                     if($1->code[0] == '%'){//Une constante
                                                      var1 = $1->var;
                                                      asprintf(&code1, "%s", $1->code);                      
                                                     }
                                                     else{
                                                      var1 = new_var();
                                                      asprintf(&code1, "%%x%d = load %s, %s \n",var1, name_of_type($1->t->tb), $1->code);
                                                    }
                                                     char *code3;
                                                     if($3->code[0] == '%'){//Une constante
                                                      var2 = $3->var;
                                                      printf("%d %s\n", $3->var, $3->code);
                                                      asprintf(&code3, "%s", $3->code);                      
                                                     }
                                                     else{
                                                      var2 = new_var();
                                                      asprintf(&code3, "%%x%d = load %s, %s \n", var2, name_of_type($3->t->tb), $3->code);
                                                    }
                                                     char *code4;
                                                     $$->var = new_var();
                                                     char *symbole_add;
                                                     if($$->t->tb == TYPE_INT){
                                                        symbole_add = "add";
                                                     }
                                                     else
                                                      symbole_add = "fadd";
                                                     asprintf(&code4, "%%x%d = %s %s %%x%d, %%x%d \n",$$->var, symbole_add, name_of_type($$->t->tb), var1, var2);
                                                     char *code;  
                                                     asprintf(&code, "%s%s%s", code1, code3, code4);
                                                     $$->code = code;
                                                     char *nom;
                                                     asprintf(&nom, "%%x%d", $$->var);
                                                     add_list(tab_symbol, $$, nom);*/
                                                    }
| additive_expression '-' multiplicative_expression {printf("additive_expression -> additive_expression '-' multiplicative_expression \n");
  }
;

comparison_expression
: shift_expression {printf("comparison_expression -> shift_expression  \n");
                    $$ = $1;
                    /*$$ = new_expr();
                    char *code;
                    $$->var = $1->var;
                    asprintf(&code, "%s", $1->code);
                    $$->code = code;*/
                   }
| comparison_expression '<' shift_expression {printf("comparison_expression -> comparison_expression '<' shift_expression \n");}
| comparison_expression '>' shift_expression {printf("comparison_expression -> comparison_expression '>' shift_expression \n");}
| comparison_expression LE_OP shift_expression {printf("comparison_expression -> comparison_expression LE_OP shift_expression \n");}
| comparison_expression GE_OP shift_expression {printf("comparison_expression -> comparison_expression GE_OP shift_expression \n");}
| comparison_expression EQ_OP shift_expression {printf("comparison_expression -> comparison_expression EQ_OP shift_expression  \n");}
| comparison_expression NE_OP shift_expression {printf("comparison_expression -> comparison_expression NE_OP shift_expression \n");}
;

expression
: unary_expression assignment_operator conditional_expression 
     {printf("expression -> unary_expression assignment_operator conditional_expression  \n");
     $$ = new_expr();
     char *code;
     int var;
     char type[1024];
     char nom_variable[1024];
     int error = sscanf($1->code, "%%x%d = load %s %s %%%s\n", &var, type, type, nom_variable); //on récupère dans nom_variable le nom de la variable dans laquelle il faut faire le store
     asprintf(&code, "%s%s %s %%x%d, %s* %%%s \n", $3->code, $2->code, name_of_type($1->t->tb), $3->var, name_of_type($1->t->tb), nom_variable);
     $$->code = code;
     }
| conditional_expression {printf("expression -> conditional_expression \n");}
;

assignment_operator
: '=' {printf("assignment_operator -> '='  \n");
       $$ = new_expr();
       char *code;
       asprintf(&code, "store");
       $$->code = code;
       }
| MUL_ASSIGN {printf("assignment_operator -> MUL_ASSIGN  \n");
              }
| DIV_ASSIGN {printf("assignment_operator -> DIV_ASSIGN  \n");}
| REM_ASSIGN {printf("assignment_operator -> REM_ASSIGN \n");}
| SHL_ASSIGN {printf("assignment_operator -> SHL_ASSIGN \n");}
| SHR_ASSIGN {printf("assignment_operator -> SHR_ASSIGN  \n");}
| ADD_ASSIGN {printf("assignment_operator -> ADD_ASSIGN  \n");}
| SUB_ASSIGN {printf("assignment_operator -> SUB_ASSIGN \n");}
;

declaration
: type_name declarator_list ';' {printf("declaration -> type_name declarator_list ';' \n");
                                 $$ = new_expr();
				 char *code1;
				 asprintf(&code1, "");
				 $$->code = code1;
                                 char code[1024] = "";
                                 char *list;
                                 struct expr *e;
                                 char *tab[strlen($2->code)];
                                 int nb_var = list_of_variable($2->code, tab);
				 char *code_expr[nb_var];
                                 for(int i = 0; i < nb_var; i++){
				    asprintf(&list, "%%%s = alloca %s\n", tab[i], $1->code);
                                    e = find_list(tab_symbol, tab[i]);
                                    e->t = new_type(type_of_name($1->code));
				    e->var = new_var();
				    asprintf(&code_expr[i], "");
				    e->code = code_expr[i];
                                    strcat(code, list);
                                 }
                                 $$->code = code;
                                 }
;

declarator_list
: declarator {printf("declarator_list -> declarator \n");
              $$ = $1;
              /*$$ = new_expr();
              char *code;
              asprintf(&code, "%s", $1->code);
              $$->code = code;*/
             }
| declarator_list ',' declarator {printf("declarator_list -> declarator_list ',' declarator \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "%s %s", $1->code, $3->code);
              $$->code = code;}
;

type_name
: VOID {printf("type_name -> VOID  \n");
       $$ = new_expr();
       $$->t = new_type(TYPE_VOID);
       char *code;
       asprintf(&code, "void");
       $$->code = code;
       }
| INT {printf("type_name -> INT \n");
       $$ = new_expr();
       $$->t = new_type(TYPE_INT);
       char *code;
       asprintf(&code, "i32");
       $$->code = code;
      }
| DOUBLE {printf("type_name -> DOUBLE \n");
          $$ = new_expr();
          $$->t = new_type(TYPE_DOUBLE);
          char *code;
          asprintf(&code, "double");
          $$->code = code;
         }
;

declarator
: IDENTIFIER {printf("declarator -> IDENTIFIER (%s)\n", $1);
              if(find_list(tab_symbol, $1) != NULL){
                error++;
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" redéfinie à la ligne %d\n", $1, yylineno);
                return 1;
              }
              if(create){
                new_element(tab_symbol);
                create = 0;
              }
	      struct expr* e = new_expr();
	      //e->var = new_var();
              char *code;
              asprintf(&code, "%s",$1);
              e->code = code;
              add_list(tab_symbol, e, $1);
	      $$ = e;
              } //ajouter dans la table de hachage(table des symboles) le nom de la variable $1 (=IDENTIFIER)
| '(' declarator ')' {printf("declarator -> '(' declarator ')' \n");}
| declarator '(' parameter_list ')' {printf("declarator -> declarator '(' parameter_list ')' \n");}
| declarator '(' ')' {printf("declarator -> declarator '(' ')' \n");
                      $$ = new_expr();
                      char *code;
                      asprintf(&code, "%s()", $1->code);
                      $$->code = code;
                     }

;

parameter_list
: parameter_declaration {printf("parameter_list -> parameter_declaration \n");}
| parameter_list ',' parameter_declaration {printf("parameter_list -> parameter_list ',' parameter_declaration \n");}
;

parameter_declaration
: type_name declarator {printf("parameter_declaration -> type_name declarator  \n");}
;

statement
: compound_statement {printf("statement -> compound_statement \n");
                      new_element(tab_symbol);
		      $$ = $1;
		      /*$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
		      delete_head(tab_symbol);
                     }
| expression_statement {printf("statement -> expression_statement \n");
                        $$ = $1;
                        /*$$ = new_expr();
                        char *code;
                        asprintf(&code, "%s", $1->code);
                        $$->code = code;*/
                       }
| selection_statement {printf("statement -> selection_statement \n");
                       $$ = $1;
                       /*$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| iteration_statement {printf("statement -> iteration_statement \n");
                       $$ = $1;
                       /*$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| jump_statement {printf("statement -> jump_statement \n");
                  $$ = $1;
                  /*$$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;*/
                 }
;

compound_statement
: '{' '}' {printf("compound_statement -> '{' '}' \n");}
| '{' statement_list '}' {printf("compound_statement -> '{' statement_list '}' \n");}
| '{' declaration_list statement_list '}' {printf("compound_statement -> '{' declaration_list statement_list '}' \n");
                                           $$ = new_expr();
                                           char *code;
                                           asprintf(&code, "{\n%s%s\n}", $2->code, $3->code);
                                           $$->code = code;
                                           
                                          }
| '{' declaration_list '}' {printf("compound_statement -> '{' declaration_list '}' \n");
                            $$ = new_expr();
                            char *code;
                            asprintf(&code, "{\n%s\n}", $2->code);
                            $$->code = code;
                           }
;

declaration_list
: declaration {printf("declaration_list -> declaration \n");
               $$ = $1;
               /*$$ = new_expr();
               char *code;
               asprintf(&code, "%s", $1->code);
               $$->code = code;*/
              }
| declaration_list declaration {printf("declaration_list -> declaration_list declaration \n");
                                $$ = new_expr();
                                char *code;
                                asprintf(&code, "%s %s", $1->code, $2->code);
                                $$->code = code;
                               }
;

statement_list
: statement {printf("statement_list -> statement \n");
             $$ = new_expr();
             char *code;
             asprintf(&code, "%s", $1->code);
             $$->code = code;
            }
| statement_list statement {printf("statement_list -> statement_list statement \n");
                            $$ = new_expr();
                            char *code;
                            asprintf(&code, "%s%s", $1->code, $2->code);
                            $$->code = code;
                           }
;

expression_statement
: ';' {printf("expression_statement -> ';'  \n");}
| expression ';' {printf("expression_statement -> expression ';' \n");
                  $$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;
                 }
;

selection_statement
: IF '(' expression ')' statement {printf("selection_statement -> IF '(' expression ')' statement \n");}
| IF '(' expression ')' statement ELSE statement {printf("selection_statement -> IF '(' expression ')' statement ELSE statement \n");}
| FOR '(' expression ';' expression ';' expression ')' statement {printf("selection_statement -> FOR '(' expression ';' expression ';' expression ')' statement \n");}
| FOR '(' expression ';' expression ';'            ')' statement {printf("selection_statement -> FOR '(' expression ';' expression ';'            ')' statement \n");}
| FOR '(' expression ';'            ';' expression ')' statement {printf("selection_statement -> FOR '(' expression ';'            ';' expression ')' statement \n");}
| FOR '(' expression ';'            ';'            ')' statement {printf("selection_statement -> FOR '(' expression ';'            ';'            ')' statement \n");}
| FOR '('            ';' expression ';' expression ')' statement {printf("selection_statement -> FOR '('            ';' expression ';' expression ')' statement \n");}
| FOR '('            ';' expression ';'            ')' statement {printf("selection_statement -> FOR '('            ';' expression ';'            ')' statement \n");}
| FOR '('            ';'            ';' expression ')' statement {printf("selection_statement -> FOR '('            ';'            ';' expression ')' statement \n");}
| FOR '('            ';'            ';'            ')' statement {printf("selection_statement -> FOR '('            ';'            ';'            ')' statement \n");}
;

iteration_statement
: WHILE '(' expression ')' statement {printf("iteration_statement -> WHILE '(' expression ')' statement \n");}
| DO statement WHILE '(' expression ')' {printf("iteration_statement -> DO statement WHILE '(' expression ')' \n");}
;

jump_statement
: RETURN ';' {printf("jump_statement -> RETURN ';' \n");}
| RETURN expression ';' {printf("jump_statement -> RETURN expression ';' \n");
                         del_carac($2->code, '*');
                         $$ = new_expr();
                         char *code;
                         asprintf(&code, "ret %s", $2->code);
                         $$->code = code;
                        }
;

main
: program {printf("main -> program \n\n\n");
           $$ = new_expr();
           char *code;
           asprintf(&code, "%s", $1->code);
           $$->code = code;
           CODE = malloc(sizeof(char) * strlen(code));
           strcpy(CODE, code);
           printf("%s\n", CODE);
          }
;

program
: external_declaration {printf("program -> external_declaration \n");
                        $$ = new_expr();
                        char *code;
                        asprintf(&code, "%s", $1->code);
                        $$->code = code;
                       }
| program external_declaration {printf("program -> program external_declaration \n");
                                $$ = new_expr();
                                char *code;
                                asprintf(&code, "%s\n%s", $1->code, $2->code);
                                $$->code = code;
                                }
;

external_declaration
: function_definition {printf("external_declaration -> function_definition \n");
                       $$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;                       
                       }
| declaration {printf("external_declaration -> declaration \n");
               $$ = new_expr();
               char *code;
               asprintf(&code, "%s", $1->code);
               $$->code = code;
              }
;

function_definition
: type_name declarator compound_statement {printf("function_definition -> type_name declarator compound_statement \n");
                                           create = 1;
                                           $$ = new_expr();
                                           char *code;
					   asprintf(&code, "define %s @%s %s", $1->code, $2->code, $3->code);
                                           $$->code = code;
                                           delete_head(tab_symbol);
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
    if(error == 0){
      char *nom = change_file_ll(file_name);
      FILE *fd = fopen(nom, "w+");
      fwrite(CODE, sizeof(char), strlen(CODE), fd);
      fclose(fd);
      free(nom);
    }
    free (file_name);
    //delete_list(tab_symbol);
    return 0;
}
