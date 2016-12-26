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
    extern struct list *tab_symbol;
    char *CODE;
    char alloc_param[1024] = "";
    int error = 0;
    int type_return_function = -1;
    int var_return;
    char name_arg[1024] = "";
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
                         $$ = cpy_expr($1);
                         /*$$ = new_expr();
                         char *code;
                         $$->var = $1->var;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;*/
                        }
;

logical_or_expression
: logical_and_expression {printf("logical_or_expression -> logical_and_expression \n");
                          $$ = cpy_expr($1);
                         }
| logical_or_expression OR logical_and_expression {printf("logical_or_expression -> logical_or_expression OR logical_and_expression \n");
                                                   $$ = new_expr();
                                                   $$->var = new_var();
                                                   char *code;
                                                   if($1->t->tb == $3->t->tb && $1->t->tb == TYPE_INT){
                                                      $$->t = new_type($1->t->tb);
                                                      asprintf(&code, "%s%s%%x%d = or i32 %%x%d, %%x%d\n", $1->code, $3->code, $$->var, $1->var, $3->var);
                                                   }
                                                   else{
                                                      char *conversion;
                                                      char *conversion1 = "";
                                                      char *conversion2 = "";
                                                      int var1 = $1->var;
                                                      int var2 = $3->var;
                                                      if($1->t->tb == TYPE_DOUBLE){
                                                        var1 = new_var();
                                                        asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                      }
                                                      if($3->t->tb == TYPE_DOUBLE){
                                                        var2 = new_var();
                                                        asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var2, $3->var);
                                                      }
                                                      asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                      asprintf(&code, "%s%s%s%%x%d = or i32 %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                    }
                                                    $$->code = code;
                                                    $$->t = new_type(TYPE_INT);
                                                  }
;

logical_and_expression
: comparison_expression {printf("logical_and_expression -> comparison_expression \n");
                         $$ = cpy_expr($1);
                         /*$$ = new_expr();
                         char *code;
                         $$->var = $1->var;
                         asprintf(&code, "%s", $1->code);
                         $$->code = code;*/
                        }
| logical_and_expression AND comparison_expression {printf("logical_and_expression -> logical_and_expression AND comparison_expression\n");
                                                    $$ = new_expr();
                                                    $$->var = new_var();
                                                    char *code;
                                                    if($1->t->tb == $3->t->tb && $1->t->tb == TYPE_INT){
                                                      $$->t = new_type($1->t->tb);
                                                      asprintf(&code, "%s%s%%x%d = and i32 %%x%d, %%x%d\n", $1->code, $3->code, $$->var, $1->var, $3->var);
                                                    }
                                                    else{
                                                      char *conversion;
                                                      char *conversion1 = "";
                                                      char *conversion2 = "";
                                                      int var1 = $1->var;
                                                      int var2 = $3->var;
                                                      if($1->t->tb == TYPE_DOUBLE){
                                                        var1 = new_var();
                                                        asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                      }
                                                      if($3->t->tb == TYPE_DOUBLE){
                                                        var2 = new_var();
                                                        asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var2, $3->var);
                                                      }
                                                      asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                      asprintf(&code, "%s%s%s%%x%d = and i32 %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                    }
                                                    $$->code = code;
                                                    $$->t = new_type(TYPE_INT);
                                                   }
;


shift_expression
: additive_expression {printf("shift_expression -> additive_expression \n");
                       $$ = cpy_expr($1);
                       /*$$ = new_expr();
                       char *code;
                       $$->var = $1->var;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| shift_expression SHL additive_expression {printf("shift_expression -> shift_expression SHL additive_expression \n");
                                            if($1->t->tb == TYPE_DOUBLE || $3->t->tb == TYPE_DOUBLE){
                                              error ++;
                                              couleur("31");
                                              printf("Erreur : ");
                                              couleur("0");
                                              printf("Opération invalide \"<<\" avec des types \"double\" à la ligne %d\n", yylineno);
                                              return 1;
                                            }
                                            $$ = new_expr();
                                            $$->var = new_var();
                                            $$->t = new_type($1->t->tb);
                                            char *code;
                                            asprintf(&code, "%s%s%%x%d = shl %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                            $$->code = code;
                                           }
| shift_expression SHR additive_expression {printf("shift_expression -> shift_expression SHR additive_expression \n");
                                            if($1->t->tb == TYPE_DOUBLE || $3->t->tb == TYPE_DOUBLE){
                                              error ++;
                                              couleur("31");
                                              printf("Erreur : ");
                                              couleur("0");
                                              printf("Opération invalide \">>\" avec des types \"double\" à la ligne %d\n", yylineno);
                                              return 1;
                                            }
                                            $$ = new_expr();
                                            $$->var = new_var();
                                            $$->t = new_type($1->t->tb);
                                            char *code;
                                            asprintf(&code, "%s%s%%x%d = ashr %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                            $$->code = code;
                                           }
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
              $$->name = e->name;
              char *code;
              char *name_x;
              asprintf(&name_x, "x%d", $$->var);
              asprintf(&code, "%%x%d = load %s, %s* %%%s\n", $$->var, name_of_type($$->t->tb), name_of_type($$->t->tb), e->name);
              $$->code = code;
              add_list(tab_symbol, $$, name_x);
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
| '(' expression ')' {printf("primary_expression -> '(' expression ')' \n");
                     }
| IDENTIFIER '(' ')' {printf("primary_expression -> IDENTIFIER '(' ')' \n");
                      $$ = new_expr();
                      struct expr *e = find_list(tab_symbol, $1);
                      if(e == NULL){
                        error ++;
                        couleur("31");
                        printf("Erreur : ");
                        couleur("0");
                        printf("Fonction \"%s\" inconnue à la ligne %d\n", $1, yylineno);
                        return 1;
                      }
                      if(e->t->is_function == 0){
                        error ++;
                        couleur("31");
                        printf("Erreur : ");
                        couleur("0");
                        printf("\"%s\" n'est pas une fonction à la ligne %d\n", $1, yylineno);
                        return 1;
                      }
                      if(e->t->nb_args > 0){
                        error ++;
                        couleur("31");
                        printf("Erreur : ");
                        couleur("0");
                        printf("Trop peu d'argument pour la fonction \"%s\" à la ligne %d\n", $1, yylineno);
                        return 1;
                      }
                      char *code;
                      if(e->t->tb != TYPE_VOID){
                        $$->var = new_var();
                        asprintf(&code, "%%x%d = call %s @%s()\n", $$->var, name_of_type(e->t->tb), $1);
                      }
                      else{
                        asprintf(&code, "call %s @%s()\n", name_of_type(e->t->tb), $1);
                      }
                      printf("%s\n", code);
                      $$->code = code;
                     } 
| IDENTIFIER '(' argument_expression_list ')' {printf("primary_expression -> IDENTIFIER '(' argument_expression_list ')' \n");
                                               $$ = new_expr();
                                               struct expr *e = find_list(tab_symbol, $1);
                                               if(e == NULL){
                                                  error ++;
                                                  couleur("31");
                                                  printf("Erreur : ");
                                                  couleur("0");
                                                  printf("Fonction \"%s\" inconnue à la ligne %d\n", $1, yylineno);
                                                  return 1;
                                               }
                                               if(e->t->is_function == 0){
                                                  error ++;
                                                  couleur("31");
                                                  printf("Erreur : ");
                                                  couleur("0");
                                                  printf("\"%s\" n'est pas une fonction à la ligne %d\n", $1, yylineno);
                                                  return 1;
                                               }
                                               char **args;
                                               args = malloc(sizeof(char));
                                               int nb_args = list_of_args($3->code, args);
                                               if(e->t->nb_args != nb_args){
                                                  error ++;
                                                  couleur("31");
                                                  printf("Erreur : ");
                                                  couleur("0");
                                                  printf("Il n'y a pas le nombre d'argument pour l'appel de la fonction \"%s\" à la ligne %d : il en faut %d et il y en a %d \n", $1, yylineno, e->t->nb_args, nb_args);
                                                  return 1;
                                               }
                                               //Conversion de type si on a pas le bon
                                               char *code;
                                               char arg[1024] = "";
                                               struct expr *e_arg;
                                               for(int i = 0; i < nb_args - 1; i++){
                                                 e_arg = find_list(tab_symbol, args[i]);
                                                 strcat(arg, name_of_type(e_arg->t->tb));
                                                 strcat(arg, " ");
                                                 strcat(arg, args[i]);
                                                 strcat(arg, ", ");
                                               }
                                               e_arg = find_list(tab_symbol, args[nb_args - 1]);
                                               strcat(arg, name_of_type(e_arg->t->tb));
                                               strcat(arg, " ");
                                               strcat(arg, args[nb_args - 1]);
                                               if(e->t->tb != TYPE_VOID){
                                                $$->var = new_var();
                                                asprintf(&code, "%s%%x%d = call %s @%s(%s)\n", $3->code, $$->var, name_of_type(e->t->tb), $1, arg);
                                               }
                                               else{
                                                asprintf(&code, "%scall %s @%s(%s)\n", $3->code, name_of_type(e->t->tb), $1, arg);
                                               }
                                               $$->code = code;
                                              }
;

postfix_expression
: primary_expression {printf("postfix_expression -> primary_expression \n");
                      $$ = cpy_expr($1);
   /*$$ = new_expr();
                      $$->t = new_type($1->t->tb);
                      $$->var = $1->var;
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
                     }
| postfix_expression INC_OP {printf("postfix_expression -> postfix_expression INC_OP \n");
                             $$ = new_expr();
                             int var = new_var();
                             char *code, *code_add;
                             if($1->t->tb == TYPE_INT){
                              asprintf(&code_add, "%%x%d = add i32 %%x%d, 1\nstore i32 %%x%d, i32* %%%s\n", var, $1->var, var, $1->name);
                             }
                             else{
                              asprintf(&code_add, "%%x%d = fadd double %%x%d, %s\nstore double %%x%d, double* %%%s\n", var, $1->var, double_to_hex_str(1.0),var, $1->name);
                             }
                             asprintf(&code, "%s%s", $1->code, code_add);
                             $$->code = code;
                            }
| postfix_expression DEC_OP {printf("postfix_expression -> postfix_expression DEC_OP \n");
                             $$ = new_expr();
                             int var = new_var();
                             char *code, *code_sub;
                             if($1->t->tb == TYPE_INT){
                              asprintf(&code_sub, "%%x%d = sub i32 %%x%d, 1\nstore i32 %%x%d, i32* %%%s\n", var, $1->var, var, $1->name);
                             }
                             else{
                              asprintf(&code_sub, "%%x%d = fsub double %%x%d, %s\nstore double %%x%d, double* %%%s\n", var, $1->var, double_to_hex_str(1.0),var, $1->name);
                             }
                             asprintf(&code, "%s%s", $1->code, code_sub);
                             $$->code = code;
                            }
;

argument_expression_list
: expression {printf("argument_expression_list -> expression \n");
              $$ = cpy_expr($1);
             }
| argument_expression_list ',' expression {printf("argument_expression_list -> argument_expression_list ',' expression \n");
                                           $$ = new_expr();
                                           char *code;
                                           asprintf(&code, "%s%s", $1->code, $3->code);
                                           $$->code = code;
                                          }
;

unary_expression
: postfix_expression {printf("unary_expression -> postfix_expression \n");
                      $$ = cpy_expr($1);
                      /*$$ = new_expr();
                      $$->t = new_type($1->t->tb);
                      $$->var = $1->var;
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
                     }
| INC_OP unary_expression {printf("unary_expression -> INC_OP unary_expression  \n");
                           $$ = new_expr();
                           int var = new_var();
                           char *code, *code_add;
                           if($2->t->tb == TYPE_INT){
                            asprintf(&code_add, "%%x%d = add i32 %%x%d, 1\nstore i32 %%x%d, i32* %%%s\n", var, $2->var, var, $2->name);
                           }
                           else{
                            asprintf(&code_add, "%%x%d = fadd double %%x%d, %s\nstore double %%x%d, double* %%%s\n", var, $2->var, double_to_hex_str(1.0),var, $2->name);
                           }
                           asprintf(&code, "%s%s", $2->code, code_add);
                           $$->code = code;
                          }
| DEC_OP unary_expression {printf("unary_expression -> DEC_OP unary_expression  \n");
                           $$ = new_expr();
                           int var = new_var();
                           char *code, *code_sub;
                           if($2->t->tb == TYPE_INT){
                            asprintf(&code_sub, "%%x%d = sub i32 %%x%d, 1\nstore i32 %%x%d, i32* %%%s\n", var, $2->var, var, $2->name);
                           }
                           else{
                            asprintf(&code_sub, "%%x%d = fsub double %%x%d, %s\nstore double %%x%d, double* %%%s\n", var, $2->var, double_to_hex_str(1.0),var, $2->name);
                           }
                           asprintf(&code, "%s%s", $2->code, code_sub);
                           $$->code = code;
                          }
| unary_operator unary_expression {printf("unary_expression -> unary_operator unary_expression \n");
                                   $$ = new_expr();
                                   char *code, var[10], signe[3], action[10], type[10], val[5];
                                   int val2;
                                   sscanf($2->code, "%s %s %s %s %s %d", var, signe, action, type, val, &val2);
                                   asprintf(&code, "%s %s %s %s %s %s%d\n", var, signe, action, type, val, $1->code, val2);
                                   $$->code = code;
                                   $$->t = $2->t;
                                   $$->var = $2->var;
                                  }
;

unary_operator
: '-' {printf("unary_operator -> '-' \n");
       $$ = new_expr();
       char *code;
       asprintf(&code, "-");
       $$->code = code;
      }
;

multiplicative_expression
: unary_expression {printf("multiplicative_expression -> unary_expression  \n");
                    $$ = cpy_expr($1);
                    /*$$ = new_expr();
                    $$->t = new_type($1->t->tb);
                    $$->var = $1->var;
                    char *code;
                    asprintf(&code, "%s", $1->code);
                    $$->code = code;*/
                   }
| multiplicative_expression '*' unary_expression {printf("multiplicative_expression -> multiplicative_expression '*' unary_expression  \n");
                                                  $$ = new_expr();
                                                  $$->var = new_var();
                                                  char *code;
                                                  if($1->t->tb == $3->t->tb){
                                                   $$->t = new_type($1->t->tb);
                                                   char *symbole_add;
                                                   if($$->t->tb == TYPE_INT){
                                                    asprintf(&symbole_add, "mul");
                                                   }
                                                   else{
                                                    asprintf(&symbole_add, "fmul");
                                                   }
                                                   asprintf(&code, "%s%s%%x%d = %s %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, symbole_add, name_of_type($1->t->tb), $1->var, $3->var);
                                                     }
                                                  else{
                                                    char *conversion = NULL;
                                                    int var1 = $1->var;
                                                    int var2 = $3->var;
                                                    if($1->t->tb == TYPE_INT){
                                                      $$->t = new_type($3->t->tb);
                                                      var1 = new_var();
                                                      asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var1, $1->var);
                                                    }
                                                    if($3->t->tb == TYPE_INT){
                                                      $$->t = new_type($1->t->tb);
                                                      var2 = new_var();
                                                      asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var2, $3->var);
                                                    }
                                                    asprintf(&code, "%s%s%s%%x%d = fmul double %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                 }
                                                 $$->code = code;
                                                 }
| multiplicative_expression '/' unary_expression {printf("multiplicative_expression -> multiplicative_expression '/' unary_expression \n");
                                                  $$ = new_expr();
                                                  $$->var = new_var();
                                                  char *code;
                                                  if($1->t->tb == $3->t->tb){
                                                   $$->t = new_type($1->t->tb);
                                                   char *symbole_add;
                                                   if($$->t->tb == TYPE_INT){
                                                    asprintf(&symbole_add, "div");
                                                   }
                                                   else{
                                                    asprintf(&symbole_add, "fdiv");
                                                   }
                                                   asprintf(&code, "%s%s%%x%d = %s %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, symbole_add, name_of_type($1->t->tb), $1->var, $3->var);
                                                  }
                                                  else{
                                                    char *conversion = NULL;
                                                    int var1 = $1->var;
                                                    int var2 = $3->var;
                                                    if($1->t->tb == TYPE_INT){
                                                      $$->t = new_type($3->t->tb);
                                                      var1 = new_var();
                                                      asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var1, $1->var);
                                                    }
                                                    if($3->t->tb == TYPE_INT){
                                                      $$->t = new_type($1->t->tb);
                                                      var2 = new_var();
                                                      asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var2, $3->var);
                                                    }
                                                    asprintf(&code, "%s%s%s%%x%d = fdiv double %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                  }
                                                  $$->code = code;
                                                 }
| multiplicative_expression REM unary_expression {printf("multiplicative_expression -> multiplicative_expression REM unary_expression  \n");
                                                  if($1->t->tb == TYPE_DOUBLE || $3->t->tb == TYPE_DOUBLE){
                                                    error ++;
                                                    couleur("31");
                                                    printf("Erreur : ");
                                                    couleur("0");
                                                    printf("Opération invalide %% avec des types \"double\" à la ligne %d\n", yylineno);
                                                    return 1;
                                                  }
                                                  $$ = new_expr();
                                                  $$->var = new_var();
                                                  $$->t = new_type($1->t->tb);
                                                  char *code;
                                                  asprintf(&code, "%s%s%%x%d = srem %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                                  $$->code = code;
                                                 }
;

additive_expression
: multiplicative_expression {printf("additive_expression -> multiplicative_expression \n");
                             $$ = cpy_expr($1);
             /*$$ = new_expr();
                             $$->t = new_type($1->t->tb);
                             $$->var = $1->var;
                             char *code;
                             asprintf(&code, "%s", $1->code);
                             $$->code = code;*/
                            }
| additive_expression '+' multiplicative_expression {printf("additive_expression ->  additive_expression '+' multiplicative_expression \n");
                                                     $$ = new_expr();
                                                     $$->var = new_var();
                                                     char *code;
                                                     if($1->t->tb == $3->t->tb){
                                                       $$->t = new_type($1->t->tb);
                                                       char *symbole_add;
                                                       if($$->t->tb == TYPE_INT){
                                                        asprintf(&symbole_add, "add");
                                                       }
                                                       else{
                                                        asprintf(&symbole_add, "fadd");
                                                       }
                                                       asprintf(&code, "%s%s%%x%d = %s %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, symbole_add, name_of_type($1->t->tb), $1->var, $3->var);
                                                     }
                                                     else{
                                                        char *conversion = NULL;
                                                        int var1 = $1->var;
                                                        int var2 = $3->var;
                                                        if($1->t->tb == TYPE_INT){
                                                          $$->t = new_type($3->t->tb);
                                                          var1 = new_var();
                                                          asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var1, $1->var);
                                                        }
                                                        if($3->t->tb == TYPE_INT){
                                                          $$->t = new_type($1->t->tb);
                                                          var2 = new_var();
                                                          asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var2, $3->var);
                                                        }
                                                        asprintf(&code, "%s%s%s%%x%d = fadd double %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                     }
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
                                                     $$ = new_expr();
                                                     $$->var = new_var();
                                                     char *code;
                                                     if($1->t->tb == $3->t->tb){
                                                       $$->t = new_type($1->t->tb);
                                                       char *symbole_add;
                                                       if($$->t->tb == TYPE_INT){
                                                        asprintf(&symbole_add, "sub");
                                                       }
                                                       else{
                                                        asprintf(&symbole_add, "fsub");
                                                       }
                                                       asprintf(&code, "%s%s%%x%d = %s %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, symbole_add, name_of_type($1->t->tb), $1->var, $3->var);
                                                     }
                                                     else{
                                                        char *conversion = NULL;
                                                        int var1 = $1->var;
                                                        int var2 = $3->var;
                                                        if($1->t->tb == TYPE_INT){
                                                          $$->t = new_type($3->t->tb);
                                                          var1 = new_var();
                                                          asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var1, $1->var);
                                                        }
                                                        if($3->t->tb == TYPE_INT){
                                                          $$->t = new_type($1->t->tb);
                                                          var2 = new_var();
                                                          asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var2, $3->var);
                                                        }
                                                        asprintf(&code, "%s%s%s%%x%d = fsub double %%x%d, %%x%d\n",$1->code, $3->code, conversion, $$->var, var1, var2);
                                                     }
                                                     $$->code = code;
                                                    }
;

comparison_expression
: shift_expression {printf("comparison_expression -> shift_expression  \n");
                    $$ = cpy_expr($1);
                    /*$$ = new_expr();
                    char *code;
                    $$->var = $1->var;
                    asprintf(&code, "%s", $1->code);
                    $$->code = code;*/
                   }
| comparison_expression '<' shift_expression {printf("comparison_expression -> comparison_expression '<' shift_expression \n");
                                              $$ = new_expr();
                                              char *code;
                                              asprintf(&code, "%s%sicmp slt %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                              $$->code = code;
                                             }
| comparison_expression '>' shift_expression {printf("comparison_expression -> comparison_expression '>' shift_expression \n");
                                              $$ = new_expr();
                                              char *code;
                                              asprintf(&code, "%s%sicmp sgt %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                              $$->code = code;
                                             }
| comparison_expression LE_OP shift_expression {printf("comparison_expression -> comparison_expression LE_OP shift_expression \n");
                                                $$ = new_expr();
                                                char *code;
                                                asprintf(&code, "%s%sicmp sge %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                                $$->code = code;
                                               }
| comparison_expression GE_OP shift_expression {printf("comparison_expression -> comparison_expression GE_OP shift_expression \n");
                                                $$ = new_expr();
                                                char *code;
                                                asprintf(&code, "%s%sicmp sle %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                                $$->code = code;
                                               }
| comparison_expression EQ_OP shift_expression {printf("comparison_expression -> comparison_expression EQ_OP shift_expression  \n");
                                                $$ = new_expr();
                                                char *code;
                                                asprintf(&code, "%s%sicmp eq %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                                $$->code = code;
                                               }
| comparison_expression NE_OP shift_expression {printf("comparison_expression -> comparison_expression NE_OP shift_expression \n");
                                                $$ = new_expr();
                                                char *code;
                                                asprintf(&code, "%s%sicmp ne %s %%x%d, %%x%d\n", $1->code, $3->code, name_of_type($1->t->tb), $1->var, $3->var);
                                                $$->code = code;
                                               }
;

expression
: unary_expression assignment_operator conditional_expression 
     {printf("expression -> unary_expression assignment_operator conditional_expression  \n");
     $$ = new_expr();
     char *code;
     char *conversion = "";
     int var;
     int var3 = $3->var;
     char type[1024];
     char nom_variable[1024];
     sscanf($1->code, "%%x%d = load %s %s %%%s\n", &var, type, type, nom_variable); //on récupère dans nom_variable le nom de la variable dans laquelle il faut faire le store
     if($1->t->tb != $3->t->tb && $3->t->tb == TYPE_DOUBLE){
      couleur("35");
      printf("Attention : ");
      couleur("0");
      printf("Conversion de type implicite à la ligne %d\n", yylineno);
      var3 = new_var();
      asprintf(&conversion, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
     }
     if($1->t->tb != $3->t->tb && $3->t->tb == TYPE_INT){
      couleur("35");
      printf("Attention : ");
      couleur("0");
      printf("Conversion de type implicite à la ligne %d\n", yylineno);
      var3 = new_var();
      asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\n", var3, $3->var);
     }
     if(strcmp($2->code, "store") == 0){
      asprintf(&code, "%s%s%s %s %%x%d, %s* %%%s \n", $3->code, conversion, $2->code, name_of_type($1->t->tb), var3, name_of_type($1->t->tb), nom_variable);
     }
     else{
      if((strcmp($2->code, "srem") == 0) || (strcmp($2->code, "shl") == 0) || (strcmp($2->code, "ashr") == 0)){//Modulo ou décalage qu'avec des entiers
        if($1->t->tb == TYPE_DOUBLE || $3->t->tb == TYPE_DOUBLE){
          error ++;
          couleur("31");
          printf("Erreur : ");
          couleur("0");
          printf("Opération invalide %% avec des types \"double\" à la ligne %d\n", yylineno);
          return 1;
        }
      }
      int var_tmp = new_var(); //stocke la valeur de la variable
      int var_res = new_var(); //stocke le résultat du calcul
      char *signe;
      if($1->t->tb == TYPE_INT){
        asprintf(&signe, "%s", $2->code);
      }
      else{
        asprintf(&signe, "f%s", $2->code);
      }
      asprintf(&code, "%s%%x%d = load %s, %s* %%%s\n%s%%x%d = %s %s %%x%d, %%x%d\nstore %s %%x%d, %s* %%%s\n", $3->code, var_tmp, name_of_type($1->t->tb), name_of_type($1->t->tb), $1->name, conversion, var_res, signe, name_of_type($1->t->tb), var_tmp, var3,name_of_type($1->t->tb), var_res, name_of_type($1->t->tb), $1->name);
     }
     $$->code = code;
     }
| conditional_expression {printf("expression -> conditional_expression \n");
                         }
;

assignment_operator
: '=' {printf("assignment_operator -> '='  \n");
       $$ = new_expr();
       char *code;
       asprintf(&code, "store");
       $$->code = code;
       }
| MUL_ASSIGN {printf("assignment_operator -> MUL_ASSIGN  \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "mul");
              $$->code = code;
             }
| DIV_ASSIGN {printf("assignment_operator -> DIV_ASSIGN  \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "div");
              $$->code = code;
             }
| REM_ASSIGN {printf("assignment_operator -> REM_ASSIGN \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "srem");
              $$->code = code;
             }
| SHL_ASSIGN {printf("assignment_operator -> SHL_ASSIGN \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "shl");
              $$->code = code;
             }
| SHR_ASSIGN {printf("assignment_operator -> SHR_ASSIGN  \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "ashr");
              $$->code = code;
             }
| ADD_ASSIGN {printf("assignment_operator -> ADD_ASSIGN  \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "add");
              $$->code = code;
             }
| SUB_ASSIGN {printf("assignment_operator -> SUB_ASSIGN \n");
              $$ = new_expr();
              char *code;
              asprintf(&code, "sub");
              $$->code = code;
             }
;

declaration
: type_name declarator_list ';' {printf("declaration -> type_name declarator_list ';' \n");
                                 $$ = new_expr();
                                 char *code1;
                                 asprintf(&code1, "");
                                 $$->code = code1;
                                 char code[1024] = "";
                                 char *list = "";
                                 struct expr *e;
                                 char *tab[strlen($2->code)];
                                 int nb_var = list_of_variable($2->code, tab);
                                 char *code_expr[nb_var];
                                 for(int i = 0; i < nb_var; i++){
                                    e = find_list(tab_symbol, tab[i]);
                                    e->t = new_type(type_of_name($1->code));
                                    e->var = new_var();
                                    asprintf(&list, "%%%s = alloca %s\n", e->name, $1->code);
                                    asprintf(&code_expr[i], "");
                                    e->code = code_expr[i];
                                    strcat(code, list);
                                 }
                                 $$->code = code;
                                 }
;

declarator_list
: declarator {printf("declarator_list -> declarator \n");
              $$ = cpy_expr($1);
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
              if(find_tab(tab_symbol->head->tab, $1) != NULL){
                error++;
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" redéfinie à la ligne %d\n", $1, yylineno);
                return 1;
              }
              struct expr* e = new_expr();
              //e->var = new_var();
              char *code;
              asprintf(&code, "%s",$1);
              e->code = code;
              e->name = code;
              add_list(tab_symbol, e, $1);
              $$ = e;
              } //ajouter dans la table de hachage(table des symboles) le nom de la variable $1 (=IDENTIFIER)
| '(' declarator ')' {printf("declarator -> '(' declarator ')' \n");
                     }
| declarator '(' parameter_list ')' {printf("declarator -> declarator '(' parameter_list ')' \n");
                                     $$ = new_expr();
                                     char *code;
                                     asprintf(&code, "%s(%s)", $1->code, $3->code);
                                     $$->code = code;
                                    }
| declarator '(' ')' {printf("declarator -> declarator '(' ')' \n");
                      $$ = new_expr();
                      char *code;
                      asprintf(&code, "%s()", $1->code);
                      $$->code = code;
                     }

;

parameter_list
: parameter_declaration {printf("parameter_list -> parameter_declaration \n"); 
                         $$ = cpy_expr($1);
                        }
| parameter_list ',' parameter_declaration {printf("parameter_list -> parameter_list ',' parameter_declaration \n");
                                            $$ = new_expr();
                                            char *code;
                                            asprintf(&code, "%s %s", $1->code, $3->code);
                                            $$->code = code;
                                           }
;

parameter_declaration
: type_name declarator {printf("parameter_declaration -> type_name declarator  \n");
                        $$ = new_expr();
                        char *code;
                        char *name;
                        char *alloc;
                        asprintf(&name, "%s", $2->code);
                        asprintf(&code, "%s %%%s", $1->code, $2->code);
                        struct expr *e = find_list(tab_symbol, $2->code);
                        e->t = new_type(type_of_name($1->code));
                        strcat(e->name, ".addr");
                        strcat(name, " ");
                        strcat(name_arg, name);
                        asprintf(&alloc, "%%%s = alloca %s\nstore %s %%%s, %s* %%%s\n", e->name, name_of_type(e->t->tb), name_of_type(e->t->tb), name, name_of_type(e->t->tb), e->name);
                        strcat(alloc_param, alloc);
                        $$->code = code;
                       }
;

statement
: compound_statement {printf("statement -> compound_statement \n");
                      $$ = cpy_expr($1);
          /*$$ = new_expr();
                      char *code;
                      asprintf(&code, "%s", $1->code);
                      $$->code = code;*/
                     }
| expression_statement {printf("statement -> expression_statement \n");
                        $$ = cpy_expr($1);
                        /*$$ = new_expr();
                        char *code;
                        asprintf(&code, "%s", $1->code);
                        $$->code = code;*/
                       }
| selection_statement {printf("statement -> selection_statement \n");
                       $$ = cpy_expr($1);
                       /*$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| iteration_statement {printf("statement -> iteration_statement \n");
                       $$ = cpy_expr($1);
                       /*$$ = new_expr();
                       char *code;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code;*/
                      }
| jump_statement {printf("statement -> jump_statement \n");
                  $$ = cpy_expr($1);
                  /*$$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;*/
                 }
;

compound_statement
: '{' '}' {printf("compound_statement -> '{' '}' \n"); 
           $$ = new_expr(); 
           $$->code = "";
          }
| '{' statement_list '}' {printf("compound_statement -> '{' statement_list '}' \n");
                          $$ = new_expr();
                          char *code;
                          asprintf(&code, "%s", $2->code);
                          $$->code = code;
                          }
| '{' declaration_list statement_list '}' {printf("compound_statement -> '{' declaration_list statement_list '}' \n");
                                           $$ = new_expr();
                                           char *code;
                                           asprintf(&code, "%s%s", $2->code, $3->code);
                                           $$->code = code;
                                          }
| '{' declaration_list '}' {printf("compound_statement -> '{' declaration_list '}' \n");
                            $$ = new_expr();
                            char *code;
                            asprintf(&code, "%s", $2->code);
                            $$->code = code;
                           }
;

declaration_list
: declaration {printf("declaration_list -> declaration \n");
               $$ = cpy_expr($1);
               /*$$ = new_expr();
               char *code;
               asprintf(&code, "%s", $1->code);
               $$->code = code;*/
              }
| declaration_list declaration {printf("declaration_list -> declaration_list declaration \n");
                                $$ = new_expr();
                                char *code;
                                asprintf(&code, "%s%s", $1->code, $2->code);
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
: ';' {printf("expression_statement -> ';'  \n");
      }
| expression ';' {printf("expression_statement -> expression ';' \n");
                  $$ = new_expr();
                  char *code;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;
                 }
;

selection_statement
: IF '(' expression ')' statement {printf("selection_statement -> IF '(' expression ')' statement \n");
                                   $$ = new_expr();
                                   char *code;
                                   char *label_if = new_label();
                                   char *label_end = new_label();
                                   asprintf(&code, "%sbr i1 %%x%d, label %%%s, label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n", $3->code, $3->var, label_if, label_end, label_if, $5->code, label_end, label_end);
                                   $$->code = code;
                                  }
| IF '(' expression ')' statement ELSE statement {printf("selection_statement -> IF '(' expression ')' statement ELSE statement \n");
                                                  $$ = new_expr();
                                                  char *code;
                                                  char *label_if = new_label();
                                                  char *label_else = new_label();
                                                  char *label_end = new_label();
                                                  asprintf(&code, "%sbr i1 %%x%d, label %%%s, label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n", $3->code, $3->var, label_if, label_else, label_if, $5->code, label_end, label_else, $7->code, label_end, label_end);
                                                  $$->code = code;
                                                 }
| FOR '(' expression ';' expression ';' expression ')' statement {printf("selection_statement -> FOR '(' expression ';' expression ';' expression ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  asprintf(&code_cond, "%s\nbr label %%%s\n\n%s:\nbr i1 %%x%d, label %%%s, label %%%s\n\n", $3->code, label_cond, label_cond, $5->var, label_body, label_end);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $9->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\n%sbr label %%%s\n\n%s:\n", label_inc, $7->code, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  printf("%s\n", code);
                                                                  $$->code = code;
                                                                 }
| FOR '(' expression ';' expression ';'            ')' statement {printf("selection_statement -> FOR '(' expression ';' expression ';'            ')' statement \n");
                                                                 }
| FOR '(' expression ';'            ';' expression ')' statement {printf("selection_statement -> FOR '(' expression ';'            ';' expression ')' statement \n");
                                                                 }
| FOR '(' expression ';'            ';'            ')' statement {printf("selection_statement -> FOR '(' expression ';'            ';'            ')' statement \n");
                                                                 }
| FOR '('            ';' expression ';' expression ')' statement {printf("selection_statement -> FOR '('            ';' expression ';' expression ')' statement \n");
                                                                 }
| FOR '('            ';' expression ';'            ')' statement {printf("selection_statement -> FOR '('            ';' expression ';'            ')' statement \n");
                                                                 }
| FOR '('            ';'            ';' expression ')' statement {printf("selection_statement -> FOR '('            ';'            ';' expression ')' statement \n");
                                                                 }
| FOR '('            ';'            ';'            ')' statement {printf("selection_statement -> FOR '('            ';'            ';'            ')' statement \n");
                                                                 }
;

iteration_statement
: WHILE '(' expression ')' statement {printf("iteration_statement -> WHILE '(' expression ')' statement \n");
                                     }
| DO statement WHILE '(' expression ')' {printf("iteration_statement -> DO statement WHILE '(' expression ')' \n");
                                        }
;

jump_statement
: RETURN ';' {printf("jump_statement -> RETURN ';' \n");
             }
| RETURN expression ';' {printf("jump_statement -> RETURN expression ';' \n");
                         $$ = new_expr();
                         char *code;
                         type_return_function = $2->t->tb;
                         var_return = $2->var;
                         asprintf(&code, "%sret %s %%x%d", $2->code, name_of_type($2->t->tb), $2->var);
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
                                           //create = 1;
                                          $$ = new_expr();
                                          char *code;
                                          char function_name[1024];
                                          struct expr *expr_arg;
                                          name_of_function($2->code, function_name);
                                          if(strcmp($1->code, "void") == 0){
                                            if(type_return_function == -1){//Ok pas de return
                                              asprintf(&code, "define %s @%s {\n%s%sret void\n}\n", $1->code, $2->code, alloc_param, $3->code);                                      
                                            }
                                            else{
                                              error++;
                                              couleur("31");
                                              printf("Erreur : ");
                                              couleur("0");
                                              printf("La fonction \"%s\" ne doit pas retourner une valeur à la ligne %d\n", function_name, yylineno);
                                              return 1;
                                            }
                                          }
                                          else{
                                            if(type_return_function == -1){
                                              couleur("35");
                                              printf("Attention : ");
                                              couleur("0");
                                              printf("Pas de valeur de retour pour la fonction %s qui doit retourner une valeur à la ligne %d\n", function_name, yylineno);
                                            }
                                            if($1->t->tb != type_return_function){
                                              couleur("35");
                                              printf("Attention : ");
                                              couleur("0");
                                              printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                              char *conversion;
                                              char *last_line;
                                              int conv = new_var();
                                              if($1->t->tb == TYPE_INT){
                                                asprintf(&last_line, "ret double %%x%d", var_return);
                                                asprintf(&conversion, "%%x%d = fptosi double %%x%d to i32\nret i32 %%x%d", conv, var_return, conv);
                                              }
                                              else{
                                                asprintf(&last_line, "ret i32 %%x%d", var_return);
                                                asprintf(&conversion, "%%x%d = sitofp i32 %%x%d to double\nret double %%x%d", conv, var_return, conv);
                                              }
                                              replace_last_line($3->code, conversion, last_line);
                                            }
                                            asprintf(&code, "define %s @%s {\n%s%s\n}\n", $1->code, $2->code, alloc_param, $3->code);
                                          }
                                          $$->code = code;
                                          struct expr *expr_function = find_list(tab_symbol, function_name);
                                          expr_function->t = new_type(type_of_name($1->code));
                                          expr_function->t->is_function = 1;
                                          char *tab_arg[strlen(name_arg)];
                                          int nb_args = list_of_variable(name_arg, tab_arg);
                                          expr_function->t->nb_args = nb_args;
                                          expr_function->t->args = malloc(sizeof(struct type) * nb_args);
                                          for(int i =0; i < nb_args; i++){
                                            expr_arg = find_tab(tab_symbol->head->tab, tab_arg[i]);
                                            expr_function->t->args[i] = expr_arg->t->tb;
                                            delete_element(tab_symbol->head->tab, tab_arg[i]);
                                          }
                                          strcpy(name_arg, "");
                                          strcpy(alloc_param, "");
                                          type_return_function = -1;
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
    delete_list(tab_symbol);
    return 0;
}
