%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "expr.h"
    #include "type.h"
    #include "utils.h"
    #include "liste.h"
    extern int yylineno;
    int yylex ();
    int yyerror ();
    struct list *tab_symbol;
    char *CODE;
    char alloc_param[1024] = "";
    int error = 0;
    enum type_base type_name_glob;
    int type_return_function = -1;
    int var_return = -1;
    char name_arg[1024] = "";
    char name_arg_func[1024][1024];
    int nb_arg_func = 0;
    int nb_arg_func_decl = 0;
    int nb_arg_func_decl_bis = 0;
    int is_func_prev = 0;
    enum type_base type_func[1024];
    struct expr *expr_arg_decl[1024];
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
%start main
%union {
  char *string;
  int i;
  double d;
  struct expr* e;
}
%%

conditional_expression
: logical_or_expression {//printf("conditional_expression -> logical_or_expression \n");
                         $$ = cpy_expr($1);
                         free_expr(&$1);
                        }
;

logical_or_expression
: logical_and_expression {//printf("logical_or_expression -> logical_and_expression \n");
                          $$ = cpy_expr($1);
                          free_expr(&$1);
                         }
| logical_or_expression OR logical_and_expression {//printf("logical_or_expression -> logical_or_expression OR logical_and_expression \n");
                                                   $$ = new_expr();
                                                  int var = new_var();
                                                  $$->var = new_var();
                                                  char *code = NULL;
                                                  char *conv;
                                                  asprintf(&conv, "%%x%d = icmp ne i32 %%x%d, 0\n", $$->var, var);                                                   
                                                  if($1->t->tb == $3->t->tb && $1->t->tb == TYPE_INT){
                                                    $$->t = new_type($1->t->tb);
                                                    asprintf(&code, "%s%s%%x%d = or i32 %%x%d, %%x%d\n%s", $1->code, $3->code, var, $1->var, $3->var, conv);
                                                  }
                                                  else{
                                                    char *conversion;
                                                    char *conversion1 = "";
                                                    char *conversion2 = "";
                                                    char *conversion3 = "";
                                                    char *conversion4 = "";
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
                                                    if($1->t->tb == TYPE_BOOL){
                                                      var1 = new_var();
                                                      asprintf(&conversion3, "%%x%d = zext i1 %%x%d to i32\n", var1, $1->var);
                                                    }
                                                    if($3->t->tb == TYPE_BOOL){
                                                      var2 = new_var();
                                                      asprintf(&conversion4, "%%x%d = zext i1 %%x%d to i32\n", var2, $3->var);
                                                    }
                                                    asprintf(&conversion, "%s%s%s%s", conversion1, conversion2, conversion3, conversion4);
                                                    asprintf(&code, "%s%s%s%%x%d = or i32 %%x%d, %%x%d\n%s",$1->code, $3->code, conversion, var, var1, var2, conv);
                                                  }

                                                  $$->code = code;
                                                  $$->t = new_type(TYPE_BOOL);
                                                  free_expr(&$1);
                                                  free_expr(&$3);
                                                  }
;

logical_and_expression
: comparison_expression {//printf("logical_and_expression -> comparison_expression \n");
                         $$ = cpy_expr($1);
                         free_expr(&$1);
                        }
| logical_and_expression AND comparison_expression {//printf("logical_and_expression -> logical_and_expression AND comparison_expression\n");
                                                    $$ = new_expr();
                                                    int var = new_var();
                                                    $$->var = new_var();
                                                    char *code = NULL;
                                                    char *conv;
                                                    asprintf(&conv, "%%x%d = icmp ne i32 %%x%d, 0\n", $$->var, var);                                                   
                                                    if($1->t->tb == $3->t->tb && $1->t->tb == TYPE_INT){
                                                      $$->t = new_type($1->t->tb);
                                                      asprintf(&code, "%s%s%%x%d = and i32 %%x%d, %%x%d\n%s", $1->code, $3->code, var, $1->var, $3->var, conv);
                                                    }
                                                    else{
                                                      char *conversion;
                                                      char *conversion1 = "";
                                                      char *conversion2 = "";
                                                      char *conversion3 = "";
                                                      char *conversion4 = "";
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
                                                      if($1->t->tb == TYPE_BOOL){
                                                        var1 = new_var();
                                                        asprintf(&conversion3, "%%x%d = zext i1 %%x%d to i32\n", var1, $1->var);
                                                      }
                                                      if($3->t->tb == TYPE_BOOL){
                                                        var2 = new_var();
                                                        asprintf(&conversion4, "%%x%d = zext i1 %%x%d to i32\n", var2, $3->var);
                                                      }
                                                      asprintf(&conversion, "%s%s%s%s", conversion1, conversion2, conversion3, conversion4);
                                                      asprintf(&code, "%s%s%s%%x%d = and i32 %%x%d, %%x%d\n%s",$1->code, $3->code, conversion, var, var1, var2, conv);
                                                    }

                                                    $$->code = code;
                                                    $$->t = new_type(TYPE_BOOL);
                                                    free_expr(&$1);
                                                    free_expr(&$3);
                                                   }
;


shift_expression
: additive_expression {//printf("shift_expression -> additive_expression \n");
                       $$ = cpy_expr($1);
                       free_expr(&$1);
                      }
| shift_expression SHL additive_expression {//printf("shift_expression -> shift_expression SHL additive_expression \n");
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
                                            char *code = NULL;
                                            asprintf(&code, "%s%s%%x%d = shl %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                            $$->code = code;
                                            free_expr(&$1);
                                            free_expr(&$3);
                                           }
| shift_expression SHR additive_expression {//printf("shift_expression -> shift_expression SHR additive_expression \n");
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
                                            char *code = NULL;
                                            asprintf(&code, "%s%s%%x%d = ashr %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                            $$->code = code;
                                            free_expr(&$1);
                                            free_expr(&$3);
                                           }
;

primary_expression
: IDENTIFIER {//printf("primary_expression -> IDENTIFIER (%s)\n", $1);
              struct expr *e = find_list(tab_symbol, $1);
              if(e == NULL){
                error ++;
                couleur("31");
                printf("Erreur : ");
                couleur("0");
                printf("Variable \"%s\" inconnue à la ligne %d\n", $1, yylineno);
                return 1;
              }
              e->use = 1;
              $$ = cpy_expr(e);
              $$->var = new_var();
              char *code = NULL;
              char *name_x = NULL;
              asprintf(&name_x, "x%d", $$->var);
              asprintf(&code, "%%x%d = load %s, %s* %s\n", $$->var, name_of_type($$->t->tb), name_of_type($$->t->tb), e->name);
              $$->code = code;
              add_list(tab_symbol, cpy_expr($$), name_x);
              free(name_x);
              }
| CONSTANTI {//printf("primary_expression -> CONSTANTI (%d)\n", $1);
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_INT);
              char *code, *name;
              asprintf(&name, "x%d", $$->var);
              asprintf(&code, "%%x%d = add i32 0, %d \n",$$->var, $1);
              add_list(tab_symbol, cpy_expr($$), name);
              $$->code = code;
            }
| CONSTANTD {//printf("primary_expression -> CONSTANTD (%f)\n", $1);
              $$=new_expr();
              $$->var=new_var();
              $$->t=new_type(TYPE_DOUBLE);
              char *code, *name;
              asprintf(&name, "x%d", $$->var);
              asprintf(&code, "%%x%d = fadd double %s, %s \n",$$->var, double_to_hex_str(0.0), double_to_hex_str($1));
              add_list(tab_symbol, cpy_expr($$), name);
              $$->code = code;
            }
| '(' expression ')' {//printf("primary_expression -> '(' expression ')' \n");
                      $$ = cpy_expr($2);
                      free_expr(&$2);
                     }
| IDENTIFIER '(' ')' {//printf("primary_expression -> IDENTIFIER '(' ')' (%s)\n", $1);
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
                      char *code = NULL;
                      if(e->t->tb != TYPE_VOID){
                        $$->var = new_var();
                        $$->t = new_type(e->t->tb);
                        asprintf(&code, "%%x%d = call %s @%s()\n", $$->var, name_of_type(e->t->tb), $1);
                      }
                      else{
                        asprintf(&code, "call %s @%s()\n", name_of_type(e->t->tb), $1);
                      }
                      $$->code = code;
                     } 
| IDENTIFIER '(' argument_expression_list ')' {//printf("primary_expression -> IDENTIFIER '(' argument_expression_list ')' (%s)\n", $1);
                                               $$ = new_expr();
                                               struct expr *e = find_list(tab_symbol, $1);
                                               int attention = 0;
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
                                               char args[1024][1024];
                                               int nb_args = compare_list(name_arg_func, nb_arg_func, $3->code, args);
                                               if(e->t->nb_args != nb_args){
                                                  error ++;
                                                  couleur("31");
                                                  printf("Erreur : ");
                                                  couleur("0");
                                                  printf("Il n'y a pas le nombre d'argument pour l'appel de la fonction \"%s\" à la ligne %d : il en faut %d et il y en a %d \n", $1, yylineno, e->t->nb_args, nb_args);
                                                  return 1;
                                               }
                                               //Conversion de type si on a pas le bon
                                               char *code = NULL;
                                               char conversion[1024] = "", *tmp_conv, *tmp_arg;
                                               int var;
                                               char arg[1024] = "";
                                               struct expr *e_arg;
                                               for(int i = 0; i < nb_args - 1; i++){
                                                 e_arg = find_list(tab_symbol, args[i]);
                                                 if(e_arg->t->tb == e->t->args[i]){
                                                   strcat(arg, name_of_type(e_arg->t->tb));
                                                   strcat(arg, " %");
                                                   strcat(arg, args[i]);
                                                   strcat(arg, ", ");
                                                 }
                                                 else{
                                                  var = new_var();
                                                  if(e->t->args[i] == TYPE_INT){
                                                    attention = 1;
                                                    asprintf(&tmp_conv, "%%x%d = fptosi double %%%s to i32\n", var, args[i]);
                                                  }
                                                  else{
                                                    attention = 1;
                                                    asprintf(&tmp_conv, "%%x%d = sitofp i32 %%%s to double\n", var, args[i]);
                                                  }
                                                  strcat(conversion, tmp_conv);
                                                  asprintf(&tmp_arg, "%s %%x%d, ", name_of_type(e->t->args[i]), var);
                                                  strcat(arg, tmp_arg);
                                                 }
                                               }
                                               e_arg = find_list(tab_symbol, args[nb_args - 1]);
                                               if(e_arg->t->tb == e->t->args[nb_args - 1]){
                                                   strcat(arg, name_of_type(e_arg->t->tb));
                                                   strcat(arg, " %");
                                                   strcat(arg, args[nb_args - 1]);
                                               }
                                               else{
                                                var = new_var();
                                                if(e->t->args[nb_args - 1] == TYPE_INT){
                                                  attention = 1;
                                                  asprintf(&tmp_conv, "%%x%d = fptosi double %%%s to i32\n", var, args[nb_args - 1]);
                                                }
                                                else{
                                                  attention = 1;
                                                  asprintf(&tmp_conv, "%%x%d = sitofp i32 %%%s to double\n", var, args[nb_args - 1]);
                                                }
                                                strcat(conversion, tmp_conv);
                                                asprintf(&tmp_arg, "%s %%x%d", name_of_type(e->t->args[nb_args - 1]), var);
                                                strcat(arg, tmp_arg);
                                               }
                                               if(attention == 1){
                                                couleur("35");
                                                printf("Attention : ");
                                                couleur("0");
                                                printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                               }
                                               if(e->t->tb != TYPE_VOID){
                                                $$->var = new_var();
                                                $$->t = new_type(e->t->tb);
                                                asprintf(&code, "%s%s%%x%d = call %s @%s(%s)\n", $3->code, conversion, $$->var, name_of_type(e->t->tb), $1, arg);
                                                char *name_x;
                                                asprintf(&name_x, "x%d", $$->var);
                                                add_list(tab_symbol, cpy_expr($$), name_x);
                                               }
                                               else{
                                                asprintf(&code, "%s%scall %s @%s(%s)\n", $3->code, conversion, name_of_type(e->t->tb), $1, arg);
                                               }
                                               $$->code = code;
                                               nb_arg_func -= e->t->nb_args;
                                               free_expr(&$3);
                                              }
;

postfix_expression
: primary_expression {//printf("postfix_expression -> primary_expression \n");
                      $$ = cpy_expr($1);
                      free_expr(&$1);
                     }
| postfix_expression INC_OP {//printf("postfix_expression -> postfix_expression INC_OP \n");
                             $$ = new_expr();
                             int var = new_var();
                             char *code, *code_add;
                             if($1->t->tb == TYPE_INT){
                              asprintf(&code_add, "%%x%d = add i32 %%x%d, 1\nstore i32 %%x%d, i32* %s\n", var, $1->var, var, $1->name);
                             }
                             else{
                              asprintf(&code_add, "%%x%d = fadd double %%x%d, %s\nstore double %%x%d, double* %s\n", var, $1->var, double_to_hex_str(1.0),var, $1->name);
                             }
                             asprintf(&code, "%s%s", $1->code, code_add);
                             $$->code = code;
                             free_expr(&$1);
                            }
| postfix_expression DEC_OP {//printf("postfix_expression -> postfix_expression DEC_OP \n");
                             $$ = new_expr();
                             int var = new_var();
                             char *code, *code_sub;
                             if($1->t->tb == TYPE_INT){
                              asprintf(&code_sub, "%%x%d = sub i32 %%x%d, 1\nstore i32 %%x%d, i32* %s\n", var, $1->var, var, $1->name);
                             }
                             else{
                              asprintf(&code_sub, "%%x%d = fsub double %%x%d, %s\nstore double %%x%d, double* %s\n", var, $1->var, double_to_hex_str(1.0),var, $1->name);
                             }
                             asprintf(&code, "%s%s", $1->code, code_sub);
                             $$->code = code;
                             free_expr(&$1);
                            }
;

argument_expression_list
: expression {//printf("argument_expression_list -> expression \n");
              char *tmp;
              asprintf(&tmp, "x%d", $1->var);
              strcpy(name_arg_func[nb_arg_func], "");
              strcat(name_arg_func[nb_arg_func], tmp);
              nb_arg_func++;
              $$ = cpy_expr($1);
              free_expr(&$1);
             }
| argument_expression_list ',' expression {//printf("argument_expression_list -> argument_expression_list ',' expression \n");
                                           $$ = new_expr();
                                           char *code = NULL;
                                           char *tmp;
                                           asprintf(&tmp, "x%d", $3->var);
                                           strcpy(name_arg_func[nb_arg_func], "");
                                           strcat(name_arg_func[nb_arg_func], tmp);
                                           nb_arg_func++;
                                           asprintf(&code, "%s%s", $1->code, $3->code);
                                           $$->code = code;
                                           free_expr(&$1);
                                           free_expr(&$3);
                                          }
;

unary_expression
: postfix_expression {//printf("unary_expression -> postfix_expression \n");
                      $$ = cpy_expr($1);
                      free_expr(&$1);
                     }
| INC_OP unary_expression {//printf("unary_expression -> INC_OP unary_expression  \n");
                           $$ = new_expr();
                           int var = new_var();
                           char *code, *code_add;
                           if($2->t->tb == TYPE_INT){
                            asprintf(&code_add, "%%x%d = add i32 %%x%d, 1\nstore i32 %%x%d, i32* %s\n", var, $2->var, var, $2->name);
                           }
                           else{
                            asprintf(&code_add, "%%x%d = fadd double %%x%d, %s\nstore double %%x%d, double* %s\n", var, $2->var, double_to_hex_str(1.0),var, $2->name);
                           }
                           asprintf(&code, "%s%s", $2->code, code_add);
                           $$->code = code;
                           free_expr(&$2);
                          }
| DEC_OP unary_expression {//printf("unary_expression -> DEC_OP unary_expression  \n");
                           $$ = new_expr();
                           int var = new_var();
                           char *code, *code_sub;
                           if($2->t->tb == TYPE_INT){
                            asprintf(&code_sub, "%%x%d = sub i32 %%x%d, 1\nstore i32 %%x%d, i32* %s\n", var, $2->var, var, $2->name);
                           }
                           else{
                            asprintf(&code_sub, "%%x%d = fsub double %%x%d, %s\nstore double %%x%d, double* %s\n", var, $2->var, double_to_hex_str(1.0),var, $2->name);
                           }
                           asprintf(&code, "%s%s", $2->code, code_sub);
                           $$->code = code;
                           free_expr(&$2);
                          }
| unary_operator unary_expression {//printf("unary_expression -> unary_operator unary_expression \n");
                                   $$ = new_expr();
                                   char *code, var[10], signe[3], action[10], type[10], val[5];
                                   char val2[10];
                                   sscanf($2->code, "%s %s %s %s %s %s", var, signe, action, type, val, val2);
                                   if($2->t->tb == TYPE_INT){
                                    asprintf(&code, "%s = %s %s %s %s%s\n", var, action, name_of_type($2->t->tb), val, $1->code, val2);
                                   }
                                   else{
                                    asprintf(&code, "%s = fsub %s %s %s\n", var, name_of_type($2->t->tb), val, val2);
                                   }
                                   $$->code = code;
                                   $$->t = cpy_type($2->t);
                                   $$->var = $2->var;
                                   free_expr(&$1);
                                   free_expr(&$2);
                                  }
;

unary_operator
: '-' {//printf("unary_operator -> '-' \n");
       $$ = new_expr();
       char *code = NULL;
       asprintf(&code, "-");
       $$->code = code;
      }
;

multiplicative_expression
: unary_expression {//printf("multiplicative_expression -> unary_expression  \n");
                    $$ = cpy_expr($1);
                    free_expr(&$1);
                   }
| multiplicative_expression '*' unary_expression {//printf("multiplicative_expression -> multiplicative_expression '*' unary_expression  \n");
                                                  $$ = new_expr();
                                                  $$->var = new_var();
                                                  char *code = NULL;
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
                                                 char *name_x;
                                                 asprintf(&name_x, "x%d", $$->var);
                                                 add_list(tab_symbol, cpy_expr($$), name_x);
                                                 $$->code = code;
                                                 free_expr(&$1);
                                                 free_expr(&$3);
                                                 }
| multiplicative_expression '/' unary_expression {//printf("multiplicative_expression -> multiplicative_expression '/' unary_expression \n");
                                                  $$ = new_expr();
                                                  $$->var = new_var();
                                                  char *code = NULL;
                                                  if($1->t->tb == $3->t->tb){
                                                   $$->t = new_type($1->t->tb);
                                                   char *symbole_add;
                                                   if($$->t->tb == TYPE_INT){
                                                    asprintf(&symbole_add, "sdiv");
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
                                                  char *name_x;
                                                  asprintf(&name_x, "x%d", $$->var);
                                                  add_list(tab_symbol, cpy_expr($$), name_x);
                                                  $$->code = code;
                                                  free_expr(&$1);
                                                  free_expr(&$3);
                                                 }
| multiplicative_expression REM unary_expression {//printf("multiplicative_expression -> multiplicative_expression REM unary_expression  \n");
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
                                                  char *code = NULL;
                                                  asprintf(&code, "%s%s%%x%d = srem %s %%x%d, %%x%d\n",$1->code, $3->code, $$->var, name_of_type($1->t->tb), $1->var, $3->var);
                                                  char *name_x;
                                                  asprintf(&name_x, "x%d", $$->var);
                                                  add_list(tab_symbol, cpy_expr($$), name_x);
                                                  $$->code = code;
                                                  free_expr(&$1);
                                                  free_expr(&$3);
                                                 }
;

additive_expression
: multiplicative_expression {//printf("additive_expression -> multiplicative_expression \n");
                             $$ = cpy_expr($1);
                             free_expr(&$1);
                            }
| additive_expression '+' multiplicative_expression {//printf("additive_expression ->  additive_expression '+' multiplicative_expression \n");
                                                     $$ = new_expr();
                                                     $$->var = new_var();
                                                     char *code = NULL;
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
                                                     char *name_x;
                                                     asprintf(&name_x, "x%d", $$->var);
                                                     add_list(tab_symbol, cpy_expr($$), name_x);
                                                     $$->code = code;
                                                     free_expr(&$1);
                                                     free_expr(&$3);
                                                    }
| additive_expression '-' multiplicative_expression {//printf("additive_expression -> additive_expression '-' multiplicative_expression \n");
                                                     $$ = new_expr();
                                                     $$->var = new_var();
                                                     char *code = NULL;
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
                                                     char *name_x;
                                                     asprintf(&name_x, "x%d", $$->var);
                                                     add_list(tab_symbol, cpy_expr($$), name_x);
                                                     $$->code = code;
                                                     free_expr(&$1);
                                                     free_expr(&$3);
                                                    }
;

comparison_expression
: shift_expression {//printf("comparison_expression -> shift_expression  \n");
                    $$ = cpy_expr($1);
                    free_expr(&$1);
                   }
| comparison_expression '<' shift_expression {//printf("comparison_expression -> comparison_expression '<' shift_expression \n");
                                              $$ = new_expr();
                                              $$->var = new_var();
                                              $$->t = new_type(TYPE_BOOL);
                                              char *code = NULL;
                                              int var1 = $1->var;
                                              int var3 = $3->var;
                                              int attention = 0;
                                              char *conversion, *conversion1 = "", *conversion2 = "";
                                              if($1->t->tb == TYPE_DOUBLE){
                                                attention = 1;
                                                var1 = new_var();
                                                asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                              }
                                              if($3->t->tb == TYPE_DOUBLE){
                                                attention = 1;
                                                var3 = new_var();
                                                asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                              }
                                              asprintf(&conversion, "%s%s", conversion1, conversion2);
                                              if(attention == 1){
                                                couleur("35");
                                                printf("Attention : ");
                                                couleur("0");
                                                printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                              }
                                              asprintf(&code, "%s%s%s%%x%d = icmp slt i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                              $$->code = code;
                                              free_expr(&$1);
                                              free_expr(&$3);
                                             }
| comparison_expression '>' shift_expression {//printf("comparison_expression -> comparison_expression '>' shift_expression \n");
                                              $$ = new_expr();
                                              $$->var = new_var();
                                              $$->t = new_type(TYPE_BOOL);
                                              char *code = NULL;
                                              int var1 = $1->var;
                                              int var3 = $3->var;
                                              int attention = 0;
                                              char *conversion, *conversion1 = "", *conversion2 = "";
                                              if($1->t->tb == TYPE_DOUBLE){
                                                attention = 1;
                                                var1 = new_var();
                                                asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                              }
                                              if($3->t->tb == TYPE_DOUBLE){
                                                attention = 1;
                                                var3 = new_var();
                                                asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                              }
                                              asprintf(&conversion, "%s%s", conversion1, conversion2);
                                              if(attention == 1){
                                                couleur("35");
                                                printf("Attention : ");
                                                couleur("0");
                                                printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                              }
                                              asprintf(&code, "%s%s%s%%x%d = icmp sgt i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                              $$->code = code;
                                              free_expr(&$1);
                                              free_expr(&$3);
                                             }
| comparison_expression LE_OP shift_expression {//printf("comparison_expression -> comparison_expression LE_OP shift_expression \n");
                                                $$ = new_expr();
                                                $$->var = new_var();
                                                $$->t = new_type(TYPE_BOOL);
                                                char *code = NULL;
                                                int var1 = $1->var;
                                                int var3 = $3->var;
                                                int attention = 0;
                                                char *conversion, *conversion1 = "", *conversion2 = "";
                                                if($1->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var1 = new_var();
                                                  asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                }
                                                if($3->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var3 = new_var();
                                                  asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                                }
                                                asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                if(attention == 1){
                                                  couleur("35");
                                                  printf("Attention : ");
                                                  couleur("0");
                                                  printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                                }                                                
                                                asprintf(&code, "%s%s%s%%x%d = icmp sge i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                                $$->code = code;
                                                free_expr(&$1);
                                                free_expr(&$3);
                                               }
| comparison_expression GE_OP shift_expression {//printf("comparison_expression -> comparison_expression GE_OP shift_expression \n");
                                                $$ = new_expr();
                                                $$->var = new_var();
                                                $$->t = new_type(TYPE_BOOL);
                                                char *code = NULL;
                                                int var1 = $1->var;
                                                int var3 = $3->var;
                                                int attention = 0;
                                                char *conversion, *conversion1 = "", *conversion2 = "";
                                                if($1->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var1 = new_var();
                                                  asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                }
                                                if($3->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var3 = new_var();
                                                  asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                                }
                                                asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                if(attention == 1){
                                                  couleur("35");
                                                  printf("Attention : ");
                                                  couleur("0");
                                                  printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                                }
                                                asprintf(&code, "%s%s%s%%x%d = icmp sle i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                                $$->code = code;
                                                free_expr(&$1);
                                                free_expr(&$3);
                                               }
| comparison_expression EQ_OP shift_expression {//printf("comparison_expression -> comparison_expression EQ_OP shift_expression  \n");
                                                $$ = new_expr();
                                                $$->var = new_var();
                                                $$->t = new_type(TYPE_BOOL);
                                                char *code = NULL;
                                                int var1 = $1->var;
                                                int var3 = $3->var;
                                                int attention = 0;
                                                char *conversion, *conversion1 = "", *conversion2 = "";
                                                if($1->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var1 = new_var();
                                                  asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                }
                                                if($3->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var3 = new_var();
                                                  asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                                }
                                                asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                if(attention == 1){
                                                  couleur("35");
                                                  printf("Attention : ");
                                                  couleur("0");
                                                  printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                                }
                                                asprintf(&code, "%s%s%s%%x%d = icmp eq i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                                $$->code = code;
                                                free_expr(&$1);
                                                free_expr(&$3);
                                               }
| comparison_expression NE_OP shift_expression {//printf("comparison_expression -> comparison_expression NE_OP shift_expression \n");
                                                $$ = new_expr();
                                                $$->var = new_var();
                                                $$->t = new_type(TYPE_BOOL);
                                                char *code = NULL;
                                                int var1 = $1->var;
                                                int var3 = $3->var;
                                                int attention = 0;
                                                char *conversion, *conversion1 = "", *conversion2 = "";
                                                if($1->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var1 = new_var();
                                                  asprintf(&conversion1, "%%x%d = fptosi double %%x%d to i32\n", var1, $1->var);
                                                }
                                                if($3->t->tb == TYPE_DOUBLE){
                                                  attention = 1;
                                                  var3 = new_var();
                                                  asprintf(&conversion2, "%%x%d = fptosi double %%x%d to i32\n", var3, $3->var);
                                                }
                                                asprintf(&conversion, "%s%s", conversion1, conversion2);
                                                if(attention == 1){
                                                  couleur("35");
                                                  printf("Attention : ");
                                                  couleur("0");
                                                  printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                                }
                                                asprintf(&code, "%s%s%s%%x%d = icmp ne i32 %%x%d, %%x%d\n", $1->code, $3->code, conversion, $$->var, var1, var3);
                                                $$->code = code;
                                                free_expr(&$1);
                                                free_expr(&$3);
                                               }
;

expression
: unary_expression assignment_operator conditional_expression 
     {//printf("expression -> unary_expression assignment_operator conditional_expression  \n");
     $$ = new_expr();
     char *code = NULL;
     char *conversion = "";
     int var3 = $3->var;
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
      asprintf(&code, "%s%s%s %s %%x%d, %s* %s\n", $3->code, conversion, $2->code, name_of_type($1->t->tb), var3, name_of_type($1->t->tb), $1->name);
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
        if((strcmp($2->code, "div") == 0)){
          asprintf(&signe, "s%s", $2->code);
        }
        else{
          asprintf(&signe, "%s", $2->code);
        }
      }
      else{
        asprintf(&signe, "f%s", $2->code);
      }
      asprintf(&code, "%s%%x%d = load %s, %s* %s\n%s%%x%d = %s %s %%x%d, %%x%d\nstore %s %%x%d, %s* %s\n", $3->code, var_tmp, name_of_type($1->t->tb), name_of_type($1->t->tb), $1->name, conversion, var_res, signe, name_of_type($1->t->tb), var_tmp, var3,name_of_type($1->t->tb), var_res, name_of_type($1->t->tb), $1->name);
     }
     $$->code = code;     
     free_expr(&$1);
     free_expr(&$2);
     free_expr(&$3);
     }
| conditional_expression {//printf("expression -> conditional_expression \n");
                          $$ = cpy_expr($1);
                          free_expr(&$1);
                         }
;

assignment_operator
: '=' {//printf("assignment_operator -> '='  \n");
       $$ = new_expr();
       char *code = NULL;
       asprintf(&code, "store");
       $$->code = code;
       }
| MUL_ASSIGN {//printf("assignment_operator -> MUL_ASSIGN  \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "mul");
              $$->code = code;
             }
| DIV_ASSIGN {//printf("assignment_operator -> DIV_ASSIGN  \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "div");
              $$->code = code;
             }
| REM_ASSIGN {//printf("assignment_operator -> REM_ASSIGN \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "srem");
              $$->code = code;
             }
| SHL_ASSIGN {//printf("assignment_operator -> SHL_ASSIGN \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "shl");
              $$->code = code;
             }
| SHR_ASSIGN {//printf("assignment_operator -> SHR_ASSIGN  \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "ashr");
              $$->code = code;
             }
| ADD_ASSIGN {//printf("assignment_operator -> ADD_ASSIGN  \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "add");
              $$->code = code;
             }
| SUB_ASSIGN {//printf("assignment_operator -> SUB_ASSIGN \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "sub");
              $$->code = code;
             }
;

declaration
: type_name declarator_list ';' {//printf("declaration -> type_name declarator_list ';' \n");
                                 $$ = new_expr();
                                 char code1[1024] = "";
                                 $$->code = code1;
                                 char *code = NULL;
                                 char *list = "";
                                 struct expr *e;
                                 char **tab;
                                 tab = malloc(sizeof(char *) * strlen($2->code));
                                 int nb_var = list_of_variable($2->code, tab);
                                 for(int i = 0; i < nb_var; i++){
                                    e = find_list(tab_symbol, tab[i]);
                                    e->t = new_type(type_of_name($1->code));
                                    e->var = new_var();
                                    asprintf(&list, "%s = alloca %s\n", e->name, $1->code);
                                    strcat(code1, list);
                                    free(list);
                                    free(tab[i]);
                                 }
                                 asprintf(&code, "%s", code1);
                                 $$->code = code;
                                 free(tab);
                                 free_expr(&$1);
                                 free_expr(&$2);
                                 }
;

declarator_list
: declarator {//printf("declarator_list -> declarator \n");
              $$ = cpy_expr($1);
              free_expr(&$1);
             }
| declarator_list ',' declarator {//printf("declarator_list -> declarator_list ',' declarator \n");
              $$ = new_expr();
              char *code = NULL;
              asprintf(&code, "%s %s", $1->code, $3->code);
              $$->code = code;
              free_expr(&$1);
              free_expr(&$3);
            }
;

type_name
: VOID {//printf("type_name -> VOID  \n");
       $$ = new_expr();
       $$->t = new_type(TYPE_VOID);
       char *code = NULL;
       asprintf(&code, "void");
       $$->code = code;
       type_name_glob = TYPE_VOID;
       }
| INT {//printf("type_name -> INT \n");
       $$ = new_expr();
       $$->t = new_type(TYPE_INT);
       char *code = NULL;
       asprintf(&code, "i32");
       $$->code = code;
       type_name_glob = TYPE_INT;
      }
| DOUBLE {//printf("type_name -> DOUBLE \n");
          $$ = new_expr();
          $$->t = new_type(TYPE_DOUBLE);
          char *code = NULL;
          asprintf(&code, "double");
          $$->code = code;
          type_name_glob = TYPE_DOUBLE;
         }
;

declarator
: IDENTIFIER {//printf("declarator -> IDENTIFIER (%s)\n", $1);
              if(is_func_prev == 0){
                if(find_tab(tab_symbol->head->tab, $1) != NULL){
                  error++;
                  couleur("31");
                  printf("Erreur : ");
                  couleur("0");
                  printf("Variable \"%s\" redéfinie à la ligne %d\n", $1, yylineno);
                  return 1;
                }
              }
              struct expr* e = new_expr();
              char *code = NULL;
              char *name = NULL;
              asprintf(&code, "%s",$1);
              e->code = code;
              e->var = new_var();
              asprintf(&name, "%%x%d_%s", e->var, code);
              e->name = name;
              if(is_func_prev == 0){
                e->real = 1;
                e->real_name = $1;
                add_list(tab_symbol, cpy_expr(e), $1);
              }
              $$ = e;
              } //ajouter dans la table de hachage(table des symboles) le nom de la variable $1 (=IDENTIFIER)
| '(' declarator ')' {//printf("declarator -> '(' declarator ')' \n");
                      $$ = cpy_expr($2);
                      free_expr(&$2);
                     }
| declarator '(' parameter_list ')' {//printf("declarator -> declarator '(' parameter_list ')' \n");
                                     $$ = new_expr();
                                     char *code = NULL;
                                     struct expr *expr_function = find_list(tab_symbol, $1->code);
                                     expr_function->t = new_type(type_name_glob);
                                     expr_function->t->is_function = 1;
                                     expr_function->use = 1;
                                     expr_function->t->nb_args = nb_arg_func_decl;
                                     expr_function->t->args = malloc(sizeof(enum type_base) * nb_arg_func_decl);
                                     for(int i = 0; i < nb_arg_func_decl; i++)
                                      expr_function->t->args[i] = type_func[i];
                                     asprintf(&code, "%s(%s)", $1->code, $3->code);
                                     $$->code = code;
                                     nb_arg_func_decl = 0;
                                     free_expr(&$1);
                                     free_expr(&$3);
                                    }
| declarator '(' ')' {//printf("declarator -> declarator '(' ')' \n");
                      $$ = new_expr();
                      char *code = NULL;
                      asprintf(&code, "%s()", $1->code);
                      struct expr *expr_function = find_list(tab_symbol, $1->code);
                      expr_function->t = new_type(type_name_glob);
                      expr_function->t->is_function = 1;
                      expr_function->use = 1;
                      $$->code = code;
                      free_expr(&$1);
                     }

;

parameter_list
: parameter_declaration {//printf("parameter_list -> parameter_declaration \n"); 
                         $$ = cpy_expr($1);
                         free_expr(&$1);
                        }
| parameter_list ',' parameter_declaration {//printf("parameter_list -> parameter_list ',' parameter_declaration \n");
                                            $$ = new_expr();
                                            char *code = NULL;
                                            asprintf(&code, "%s, %s", $1->code, $3->code);
                                            $$->code = code;
                                            free_expr(&$1);
                                            free_expr(&$3);
                                           }
;

is_func
: {is_func_prev = 1;}

parameter_declaration
: is_func type_name declarator {//printf("parameter_declaration -> type_name declarator  \n");
                        $$ = new_expr();
                        char *code = NULL;
                        char *name = NULL;
                        char *alloc = NULL;
                        type_func[nb_arg_func_decl] = type_of_name($2->code);
                        nb_arg_func_decl ++;
                        asprintf(&name, "%s", $3->code);
                        asprintf(&code, "%s %%%s", $2->code, $3->code);
                        struct expr *e = new_expr();
                        e->t = new_type(type_of_name($2->code));
                        asprintf(&e->name, "%%%s.addr", $3->code);
                        strcat(name, " ");
                        strcat(name_arg, name);
                        asprintf(&alloc, "%s = alloca %s\nstore %s %%%s, %s* %s\n", e->name, name_of_type(e->t->tb), name_of_type(e->t->tb), name, name_of_type(e->t->tb), e->name);
                        expr_arg_decl[nb_arg_func_decl_bis] = cpy_expr(e);
                        nb_arg_func_decl_bis ++;
                        strcat(alloc_param, alloc);
                        $$->code = code;
                        free_expr(&$2);
                        free_expr(&$3);
                       }
;

statement
: compound_statement {//printf("statement -> compound_statement \n");
                      $$ = cpy_expr($1);
                      free_expr(&$1);
                     }
| expression_statement {//printf("statement -> expression_statement \n");
                        $$ = cpy_expr($1);
                        free_expr(&$1);
                       }
| selection_statement {//printf("statement -> selection_statement \n");
                       $$ = cpy_expr($1);
                       free_expr(&$1);
                      }
| iteration_statement {//printf("statement -> iteration_statement \n");
                       $$ = cpy_expr($1);
                       free_expr(&$1);
                      }
| jump_statement {//printf("statement -> jump_statement \n");
                  $$ = cpy_expr($1);
                  free_expr(&$1);
                 }
;

create_tab
: {new_element(tab_symbol);
   if(nb_arg_func_decl_bis > 0){
    char **tab_arg;
    tab_arg = malloc(sizeof(char *) * strlen(name_arg));
    list_of_variable(name_arg, tab_arg);
    for(int i = 0; i < nb_arg_func_decl_bis; i++){
      add_list(tab_symbol, expr_arg_decl[i], tab_arg[i]);
      free(tab_arg[i]);
    } 
    nb_arg_func_decl_bis = 0;
    is_func_prev = 0;
    strcpy(name_arg, "");
    free(tab_arg);
   }
  }
;

compound_statement
: '{' create_tab '}' {//printf("compound_statement -> '{' '}' \n"); 
                       $$ = new_expr(); 
                       $$->code = "";
                       delete_head(tab_symbol);
                     }
| '{' create_tab statement_list '}' {//printf("compound_statement -> '{' statement_list '}' \n");
                          $$ = cpy_expr($3);
                          delete_head(tab_symbol);
                          free_expr(&$3);
                          }
| '{' create_tab declaration_list statement_list '}' {//printf("compound_statement -> '{' declaration_list statement_list '}' \n");
                                           $$ = new_expr();
                                           char *code = NULL;
                                           asprintf(&code, "%s%s", $3->code, $4->code);
                                           $$->code = code;
                                           delete_head(tab_symbol);
                                           free_expr(&$3);
                                           free_expr(&$4);
                                          }
| '{' create_tab declaration_list '}' {//printf("compound_statement -> '{' declaration_list '}' \n");
                            $$ = cpy_expr($3);
                            delete_head(tab_symbol);
                            free_expr(&$3);
                           }
;

declaration_list
: declaration {//printf("declaration_list -> declaration \n");
               $$ = cpy_expr($1);
               free_expr(&$1);
              }
| declaration_list declaration {//printf("declaration_list -> declaration_list declaration \n");
                                $$ = new_expr();
                                char *code = NULL;
                                asprintf(&code, "%s%s", $1->code, $2->code);
                                $$->code = code;
                                free_expr(&$1);
                                free_expr(&$2);
                               }
;

statement_list
: statement {//printf("statement_list -> statement \n");

             $$ = new_expr();
             char *code = NULL;
             asprintf(&code, "%s", $1->code);
             $$->code = code;
             free_expr(&$1);
            }
| statement_list statement {//printf("statement_list -> statement_list statement \n");
                            $$ = new_expr();
                            char *code = NULL;
                            asprintf(&code, "%s%s", $1->code, $2->code);
                            $$->code = code;
                            free_expr(&$1);
                            free_expr(&$2);
                           }
;

expression_statement
: ';' {//printf("expression_statement -> ';'  \n");
       $$ = new_expr();
       char *code = "";
       $$->code = code;
      }
| expression ';' {//printf("expression_statement -> expression ';' \n");
                  $$ = new_expr();
                  char *code = NULL;
                  asprintf(&code, "%s", $1->code);
                  $$->code = code;
                  free_expr(&$1);
                 }
;

selection_statement
: IF '(' expression ')' statement {//printf("selection_statement -> IF '(' expression ')' statement \n");
                                   $$ = new_expr();
                                   char *code = NULL;
                                   char *label_if = new_label();
                                   char *label_end = new_label();
                                   char *conv = "", *conversion1 = "", *conversion2 = "";
                                   if($3->t->tb == TYPE_INT){
                                     int var = $3->var;
                                     $3->var = new_var();
                                     asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $3->var, var);
                                   }
                                   if($3->t->tb == TYPE_DOUBLE){
                                     int var = $3->var;
                                     $3->var = new_var();
                                     asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $3->var, var);
                                   }
                                   asprintf(&conv, "%s%s", conversion1, conversion2);
                                   asprintf(&code, "%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n", $3->code, conv, $3->var, label_if, label_end, label_if, $5->code, label_end, label_end);
                                   $$->code = code;
                                   free_expr(&$3);
                                   free_expr(&$5);
                                  }
| IF '(' expression ')' statement ELSE statement {//printf("selection_statement -> IF '(' expression ')' statement ELSE statement \n");
                                                  $$ = new_expr();
                                                  char *code = NULL;
                                                  char *label_if = new_label();
                                                  char *label_else = new_label();
                                                  char *label_end = new_label();
                                                  char *conv = "", *conversion1 = "", *conversion2 = "";
                                                  if($3->t->tb == TYPE_INT){
                                                   int var = $3->var;
                                                   $3->var = new_var();
                                                   asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $3->var, var);
                                                  }
                                                  if($3->t->tb == TYPE_DOUBLE){
                                                   int var = $3->var;
                                                   $3->var = new_var();
                                                   asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $3->var, var);
                                                  }
                                                  asprintf(&conv, "%s%s", conversion1, conversion2);
                                                  asprintf(&code, "%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n%sbr label %%%s\n\n%s:\n", $3->code, conv, $3->var, label_if, label_else, label_if, $5->code, label_end, label_else, $7->code, label_end, label_end);
                                                  $$->code = code;
                                                  free_expr(&$3);
                                                  free_expr(&$5);
                                                  free_expr(&$7);
                                                 }
| FOR '(' expression ';' expression ';' expression ')' statement {//printf("selection_statement -> FOR '(' expression ';' expression ';' expression ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond = NULL;
                                                                  char *code_body = NULL;
                                                                  char *code_inc = NULL;
                                                                  char *conv = "", *conversion1 = "", *conversion2 = "";
                                                                  if($5->t->tb == TYPE_INT){
                                                                     int var = $5->var;
                                                                     $5->var = new_var();
                                                                     asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $5->var, var);
                                                                   }
                                                                  if($5->t->tb == TYPE_DOUBLE){
                                                                     int var = $5->var;
                                                                     $5->var = new_var();
                                                                     asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $5->var, var);
                                                                   }
                                                                  asprintf(&conv, "%s%s", conversion1, conversion2);
                                                                  asprintf(&code_cond, "%sbr label %%%s\n\n%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n", $3->code, label_cond, label_cond, $5->code, conv, $5->var, label_body, label_end);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $9->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\n%sbr label %%%s\n\n%s:\n", label_inc, $7->code, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$3);
                                                                  free_expr(&$5);
                                                                  free_expr(&$7);
                                                                  free_expr(&$9);
                                                                 }
| FOR '(' expression ';' expression ';'            ')' statement {//printf("selection_statement -> FOR '(' expression ';' expression ';'            ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  char *conv = "", *conversion1 = "", *conversion2 = "";
                                                                  if($5->t->tb == TYPE_INT){
                                                                     int var = $5->var;
                                                                     $5->var = new_var();
                                                                     asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $5->var, var);
                                                                   }
                                                                  if($5->t->tb == TYPE_DOUBLE){
                                                                     int var = $5->var;
                                                                     $5->var = new_var();
                                                                     asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $5->var, var);
                                                                   }
                                                                  asprintf(&conv, "%s%s", conversion1, conversion2);
                                                                  asprintf(&code_cond, "%sbr label %%%s\n\n%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n", $3->code, label_cond, label_cond, $5->code, conv, $5->var, label_body, label_end);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $8->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\nbr label %%%s\n\n%s:\n", label_inc, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$3);
                                                                  free_expr(&$5);
                                                                  free_expr(&$8);
                                                                 }
| FOR '(' expression ';'            ';' expression ')' statement {//printf("selection_statement -> FOR '(' expression ';'            ';' expression ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  asprintf(&code_cond, "%sbr label %%%s\n\n%s:\nbr label %%%s\n\n", $3->code, label_cond, label_cond, label_body);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $8->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\n%sbr label %%%s\n\n%s:\n", label_inc, $6->code, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$3);
                                                                  free_expr(&$6);
                                                                  free_expr(&$8);
                                                                 }
| FOR '(' expression ';'            ';'            ')' statement {//printf("selection_statement -> FOR '(' expression ';'            ';'            ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  asprintf(&code_cond, "%sbr label %%%s\n\n%s:\nbr label %%%s\n\n", $3->code, label_cond, label_cond, label_body);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $7->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\nbr label %%%s\n\n%s:\n", label_inc, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$3);
                                                                  free_expr(&$7);
                                                                 }
| FOR '('            ';' expression ';' expression ')' statement {//printf("selection_statement -> FOR '('            ';' expression ';' expression ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  char *conv = "", *conversion1 = "", *conversion2 = "";
                                                                  if($4->t->tb == TYPE_INT){
                                                                     int var = $4->var;
                                                                     $4->var = new_var();
                                                                     asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $4->var, var);
                                                                   }
                                                                  if($4->t->tb == TYPE_DOUBLE){
                                                                     int var = $4->var;
                                                                     $4->var = new_var();
                                                                     asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $4->var, var);
                                                                   }
                                                                  asprintf(&conv, "%s%s", conversion1, conversion2);
                                                                  asprintf(&code_cond, "br label %%%s\n\n%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n", label_cond, label_cond, $4->code, conv, $4->var, label_body, label_end);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $8->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\n%sbr label %%%s\n\n%s:\n", label_inc, $6->code, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$4);
                                                                  free_expr(&$6);
                                                                  free_expr(&$8);
                                                                 }
| FOR '('            ';' expression ';'            ')' statement {//printf("selection_statement -> FOR '('            ';' expression ';'            ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  char *conv = "", *conversion1 = "", *conversion2 = "";
                                                                  if($4->t->tb == TYPE_INT){
                                                                     int var = $4->var;
                                                                     $4->var = new_var();
                                                                     asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $4->var, var);
                                                                   }
                                                                  if($4->t->tb == TYPE_DOUBLE){
                                                                     int var = $4->var;
                                                                     $4->var = new_var();
                                                                     asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $4->var, var);
                                                                   }
                                                                  asprintf(&conv, "%s%s", conversion1, conversion2);
                                                                  asprintf(&code_cond, "br label %%%s\n\n%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n", label_cond, label_cond, $4->code, conv, $4->var, label_body, label_end);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $7->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\nbr label %%%s\n\n%s:\n", label_inc, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$4);
                                                                  free_expr(&$7);
                                                                 }
| FOR '('            ';'            ';' expression ')' statement {//printf("selection_statement -> FOR '('            ';'            ';' expression ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  asprintf(&code_cond, "br label %%%s\n\n%s:\nbr label %%%s\n\n", label_cond, label_cond, label_body);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $7->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\n%sbr label %%%s\n\n%s:\n", label_inc, $5->code, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$5);
                                                                  free_expr(&$7);
                                                                 }
| FOR '('            ';'            ';'            ')' statement {//printf("selection_statement -> FOR '('            ';'            ';'            ')' statement \n");
                                                                  $$ = new_expr();
                                                                  char *label_cond = new_label();
                                                                  char *label_body = new_label();
                                                                  char *label_inc = new_label();
                                                                  char *label_end = new_label();
                                                                  char *code = NULL;
                                                                  char *code_cond;
                                                                  char *code_body;
                                                                  char *code_inc;
                                                                  asprintf(&code_cond, "br label %%%s\n\n%s:\nbr label %%%s\n\n", label_cond, label_cond, label_body);
                                                                  asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $6->code, label_inc);
                                                                  asprintf(&code_inc, "%s:\nbr label %%%s\n\n%s:\n", label_inc, label_cond, label_end);
                                                                  asprintf(&code, "%s%s%s", code_cond, code_body, code_inc);
                                                                  $$->code = code;
                                                                  free_expr(&$6);
                                                                 }
;

iteration_statement
: WHILE '(' expression ')' statement {//printf("iteration_statement -> WHILE '(' expression ')' statement \n");
                                      $$ = new_expr();
                                      char *label_cond = new_label();
                                      char *label_body = new_label();
                                      char *label_end = new_label();
                                      char *code = NULL;
                                      char *code_cond;
                                      char *code_body;
                                      char *conv = "", *conversion1 = "", *conversion2 = "";
                                      if($3->t->tb == TYPE_INT){
                                         int var = $3->var;
                                         $3->var = new_var();
                                         asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $3->var, var);
                                       }
                                      if($3->t->tb == TYPE_DOUBLE){
                                         int var = $3->var;
                                         $3->var = new_var();
                                         asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $3->var, var);
                                       }
                                      asprintf(&conv, "%s%s", conversion1, conversion2);
                                      asprintf(&code_cond, "br label %%%s\n\n%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n", label_cond, label_cond, $3->code, conv, $3->var, label_body, label_end);
                                      asprintf(&code_body, "%s:\n%sbr label %%%s\n\n%s:\n", label_body, $5->code, label_cond, label_end);
                                      asprintf(&code, "%s%s", code_cond, code_body);
                                      $$->code = code;
                                      free_expr(&$3);
                                      free_expr(&$5);
                                     }
| DO statement WHILE '(' expression ')' {//printf("iteration_statement -> DO statement WHILE '(' expression ')' \n");
                                         $$ = new_expr();
                                         char *label_body = new_label();
                                         char *label_cond = new_label();
                                         char *label_end = new_label();
                                         char *code = NULL;
                                         char *code_cond;
                                         char *code_body;
                                         char *conv = "", *conversion1 = "", *conversion2 = "";
                                         if($5->t->tb == TYPE_INT){
                                           int var = $5->var;
                                           $5->var = new_var();
                                           asprintf(&conversion1, "%%x%d = icmp ne i32 %%x%d, 0\n", $5->var, var);
                                         }
                                         if($5->t->tb == TYPE_DOUBLE){
                                           int var = $5->var;
                                           $5->var = new_var();
                                           asprintf(&conversion2, "%%x%d = fcmp one double %%x%d, 0.0\n", $5->var, var);
                                         }
                                         asprintf(&conv, "%s%s", conversion1, conversion2);
                                         asprintf(&code_cond, "%s:\n%s%sbr i1 %%x%d, label %%%s, label %%%s\n\n%s:\n", label_cond, $5->code, conv, $5->var, label_body, label_end, label_end);
                                         asprintf(&code_body, "%s:\n%sbr label %%%s\n\n", label_body, $2->code, label_cond);
                                         asprintf(&code, "%s%s", code_body, code_cond);
                                         $$->code = code;
                                         free_expr(&$2);
                                         free_expr(&$5);
                                        }
;

jump_statement
: RETURN ';' {//printf("jump_statement -> RETURN ';' \n");
              $$ = new_expr();
              char *code = NULL;
              type_return_function = 2;
              asprintf(&code, "ret void\n");
              $$->code = code;
             }
| RETURN expression ';' {//printf("jump_statement -> RETURN expression ';' \n");
                         $$ = new_expr();
                         if(var_return == -1){
                          var_return = new_var();
                         }
                         char *code = NULL;
                         type_return_function = $2->t->tb;
                         asprintf(&code, "%sstore %s %%x%d, %s* %%x%d\n", $2->code, name_of_type($2->t->tb), $2->var, name_of_type($2->t->tb), var_return);
                         $$->code = code;
                         free_expr(&$2);
                        }
;

main
: program {//printf("main -> program \n\n\n");
           char *code = NULL;
           char *function = NULL;
           function = add_function_declaration();
           asprintf(&code, "%s", $1->code);
           asprintf(&CODE, "%s%s", function, code);
           free_expr(&$1);
           free(function);
           free(code);
          }
;

program
: external_declaration {//printf("program -> external_declaration \n");
                        $$ = new_expr();
                        char *code = NULL;
                        asprintf(&code, "%s", $1->code);
                        $$->code = code;
                        free_expr(&$1);
                       }
| program external_declaration {//printf("program -> program external_declaration \n");
                                $$ = new_expr();
                                char *code = NULL;
                                asprintf(&code, "%s%s", $1->code, $2->code);
                                $$->code = code;
                                free_expr(&$1);
                                free_expr(&$2);
                                }
;

external_declaration
: function_definition {//printf("external_declaration -> function_definition \n");
                       $$ = new_expr();
                       char *code = NULL;
                       asprintf(&code, "%s", $1->code);
                       $$->code = code; 
                       free_expr(&$1);                      
                       }
| declaration {//printf("external_declaration -> declaration \n");
               $$ = new_expr();
               char *code = NULL, *code_aux = NULL; 
               char arg[1024] = "";
               char **tab;
               tab = malloc(sizeof(char *) * strlen($1->code));
               int nb = list_of_args($1->code, tab);
               struct expr *e[nb];
               for(int i = 0; i < nb; i++){
                 e[i] = find_list(tab_symbol, tab[i]);
                 asprintf(&e[i]->name, "@%s", tab[i]);
                 if(e[i]->t->tb == TYPE_INT){
                  asprintf(&code_aux, "%s = common global i32 0\n", e[i]->name);
                 }
                 else{
                  asprintf(&code_aux, "%s = common global double %s\n", e[i]->name, double_to_hex_str(0.0));
                 }
                 strcat(arg, code_aux);
                 free(code_aux);
                 free(tab[i]);
              }
               asprintf(&code, "%s", arg);
               $$->code = code;
               free_expr(&$1);
               free(tab);
              }
;

function_definition
: type_name declarator compound_statement {//printf("function_definition -> type_name declarator compound_statement \n");
                                          $$ = new_expr();
                                          char *code = NULL;
                                          char function_name[1024];
                                          int var_r;
                                          char *name_var_return;
                                          name_of_function($2->code, function_name);
                                          if(strcmp($1->code, "void") == 0){
                                            if(type_return_function == -1){//Ok pas de return
                                              asprintf(&code, "\ndefine %s @%s {\n%s%sret void\n}\n", $1->code, $2->code, alloc_param, $3->code);                                      
                                            }
                                            else if(type_return_function == 2){//Return vide
                                              asprintf(&code, "\ndefine %s @%s {\n%s%s\n}\n", $1->code, $2->code, alloc_param, $3->code);                                      
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
                                              error ++;
                                              couleur("31");
                                              printf("Erreur : ");
                                              couleur("0");
                                              printf("Pas de valeur de retour pour la fonction %s qui doit retourner une valeur à la ligne %d\n", function_name, yylineno);
                                              return 1;
                                            }
                                            asprintf(&name_var_return, "%%x%d", var_return);
                                            char *conv = conv_ret($3->code, $1->t->tb, name_var_return);
                                            if(strlen(conv) > strlen($3->code)){
                                              couleur("35");
                                              printf("Attention : ");
                                              couleur("0");
                                              printf("Conversion de type implicite à la ligne %d\n", yylineno);
                                            }
                                            var_r = new_var();
                                            asprintf(&code, "\ndefine %s @%s {\n%%x%d = alloca %s\n%s%s%%x%d = load %s, %s* %%x%d\nret %s %%x%d\n}\n", $1->code, $2->code, var_return, name_of_type($1->t->tb), alloc_param, conv, var_r, name_of_type($1->t->tb), name_of_type($1->t->tb), var_return, name_of_type($1->t->tb), var_r);
                                          }
                                          $$->code = code;
                                          strcpy(alloc_param, "");
                                          type_return_function = -1;
                                          free_expr(&$1);
                                          free_expr(&$2);
                                          free_expr(&$3);
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
  add_basic_function(tab_symbol);
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
      free(CODE);
      return 0;
    }
    free (file_name);
    delete_list(tab_symbol);
    return 0;
}
