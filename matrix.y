%{
 
#include "simple.h"
#include <string.h>
bool error_syntaxical=false;
extern unsigned int lineno;
extern bool error_lexical;

 
%}
 

/* L'union dans Bison est utilisee pour typer nos tokens ainsi que nos non terminaux. Ici nous avons declare une union avec deux types : nombre de type int et texte de type pointeur de char (char*) */
 
%union {
        long nombre;
        char* texte;
}
 

/* Nous avons ici les operateurs, ils sont definis par leur ordre de priorite. Si je definis par exemple la multiplication en premier et l'addition apres, le + l'emportera alors sur le * dans le langage. Les parenthese sont prioritaires avec %right */
 

%left                   TOK_ADD        TOK_DIFF     /* +- */
%left                   TOK_MULT       TOK_DIV         /* /* */
%left                   TOK_PUISS                       /* ^ */
%left                   TOK_VER
%right                  TOK_PARG        TOK_PARD        /* () */
%right                  TOK_PG        TOK_PD        /* [] */


 
/* Nous avons la liste de nos expressions (les non terminaux). Nous les typons tous en texte (pointeur vers une zone de char). */
 

%type<texte>            code
%type<texte>            BEGIN
%type<texte>            FIN
%type<texte>            instruction
%type<texte>            variable_identificateur
%type<texte>            variable_arithmetique
%type<texte>            affectation
%type<texte>            affichage
%type<texte>            expression_arithmetique
%type<texte>            expression_identificateur
%type<texte>            addition
%type<texte>            difference
%type<texte>            multiplication
%type<texte>            puissance
 

/* Nous avons la liste de nos tokens (les terminaux de notre grammaire) */
 

%token<texte>           TOK_NOMBRE
%token                  TOK_BEGIN        /* BEGIN */
%token                  TOK_FIN        /* FIN. */
%token                  TOK_AFFECT      /* := */
%token                  TOK_FINSTR      /* ; */
%token                  TOK_VER         /* , */
%token                  TOK_POINT         /* . */
%token                  TOK_AFFICHER    /* afficher */
%token                  TOK_SUPPR       /* supprimer */
%token<texte>           TOK_VARE        /* variable arithmetique */
%token<texte>           TOK_VARB        /* variable identificateur */
 

%%
 

/* Nous definissons toutes les regles grammaticales de chaque non terminal de notre langage. Par defaut on commence a definir l'axiome, c'est a dire ici le non terminal code. Si nous le definissons pas en premier nous devons le specifier en option dans Bison avec %start */
 

code:           %empty{}
                |
                code instruction{
                        printf("\t\t\t Resultat : C'est une instruction valide !\n\n");
                }
                |
                code error{
                        fprintf(stderr,"\t\t\t ERREUR : Erreur de syntaxe a la ligne %d.\n",lineno);
                        error_syntaxical=true;
                };
 

instruction:    affectation{
                        printf("\t\t\t\tInstruction type Affectation\n");
                }
                |
                affichage{
                         printf("\t\t\t\tInstruction type Affichage\n");
                }
                |
                BEGIN{
                         printf("\t\t\t\tInstruction type BEGIN\n");
                }
                |
                FIN{
                        printf("\t\t\t\tInstruction type FIN\n");
                };
            

 
variable_identificateur: TOK_VARB{
                                printf("\t\t\tVariable %s\n",$1);
                                $$=strdup($1);
                        };
                        

                        
variable_arithmetique:  TOK_VARE{
                                printf("\t\t\tVariable %s\n",$1);
                                $$=strdup($1);
                        };
                    
 

affectation:    variable_identificateur TOK_AFFECT expression_identificateur TOK_FINSTR{
                        /* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
                        printf("\t\tAffectation sur la variable %s\n",$1);
                }
                |
                variable_identificateur TOK_AFFECT expression_arithmetique TOK_FINSTR{
                        printf("\t\tAffectation sur l'identificateur %s\n",$1);
                };
                


affichage:      TOK_AFFICHER expression_identificateur TOK_FINSTR{
                        printf("\t\tAffichage de la valeur de l'expression %s\n",$2);
                };
                

BEGIN:          TOK_BEGIN  {
                        printf("\t\tdemarrage avec BEGIN\n");
                };
                

FIN:           TOK_FIN {
                        printf("\t\tFermeture avec FIN\n");
                };
                
                
 
expression_identificateur:      variable_identificateur{
                                        $$=strdup($1);
                                }
                                |
                                addition{
                                }
                                |
                                difference{
                                }
                                |
                                multiplication{
                                }
                                |
                                puissance{
                                }
                                |
                                TOK_PARG expression_identificateur TOK_PARD{
                                        $$=strcat(strcat(strdup("("),strdup($2)),strdup(")"));
                                }
                                |
                                TOK_PG expression_identificateur TOK_VER expression_identificateur TOK_PD{
                                        $$=strcat(strcat(strcat(strdup("["),strdup($2)),strcat(strdup(","),strdup($4))),strdup("]"));
                                };


                            
 
expression_arithmetique:       TOK_NOMBRE{
                                        printf("\t\t\tNombre : %ld\n",$1);
                                        /* Comme le token TOK_NOMBRE est de type entier et que on a type expression_arithmetique comme du texte, il nous faut convertir la valeur en texte. */
                                        int length=snprintf(NULL,0,"%ld",$1);
                                        char* str=malloc(length+1);
                                        snprintf(str,length+1,"%ld",$1);
                                        $$=strdup(str);
                                        free(str);
                                }
                                |
                                variable_arithmetique{
                                      $$=strdup($1);
                                }
                                |
                                TOK_PG TOK_PARG expression_arithmetique TOK_VER expression_arithmetique TOK_PARD 
                                TOK_VER TOK_PARG expression_arithmetique TOK_VER expression_arithmetique TOK_PARD TOK_PD{
                                        printf("\t\t\t Matrice syntaxe réussi ! \n");
                                        $$=strcat(strcat(strcat(strcat(strdup("["),strdup("(")),strcat(strdup($3),strdup(","))),
                                        strcat(strcat(strdup($5),strdup(")")),strcat(strdup(","),strdup("(")))),
                                        strcat(strcat(strcat(strdup($9),strdup(",")),strcat(strdup($11),strdup(")"))),strdup("]")));
                                };
                                
    
                               
 
addition:  expression_identificateur TOK_ADD expression_identificateur{
        printf("\t\t\t ---------- Addition ---------- \n");$$=strcat(strcat(strdup($1),strdup("+")),strdup($3));
        };

difference:   expression_identificateur TOK_DIFF expression_identificateur{
        printf("\t\t\t ---------- Difference ----------\n");$$=strcat(strcat(strdup($1),strdup("-")),strdup($3));
        };

multiplication: expression_identificateur TOK_MULT expression_identificateur{
        printf("\t\t\t ---------- Multiplication ---------- \n");$$=strcat(strcat(strdup($1),strdup("*")),strdup($3));
        };

puissance: expression_identificateur TOK_PUISS expression_arithmetique{
        printf("\t\t\t ---------- Puissance Carre ----------\n");$$=strcat(strcat(strdup($1),strdup("^")),strdup($3));
        };

 
%%
 
/* Dans la fonction main on appelle bien la routine yyparse() qui sera genere par Bison. Cette routine appellera yylex() de notre analyseur lexical. */
 
int main(void){
        printf("*****************************************************************************************************************\n");
        printf("********************************************Debut de l'analyse syntaxique :**************************************\n");
        printf("*****************************************************************************************************************\n");
        yyparse();
        printf("*****************************************************************************************************************\n");
        printf("*********************************************  Fin de l'analyse !  **********************************************\n");
        printf("*****************************************************************************************************************\n");
        printf("************************************************* Resultat : ****************************************************\n");
        printf("*****************************************************************************************************************\n");
        if(error_lexical){
                printf("\t----------------- Echec : Certains lexemes ne font pas partie du lexique du langage ! -----------------\n");
                printf("\t------------------------------------ Echec a l'analyse lexicale ---------------------------------------\n");
        }
        else{
                printf("\t----------------------------------- Succes a l'analyse lexicale ! -------------------------------------\n");
        }
        if(error_syntaxical){
                printf("\t----------------- Echec : Certaines phrases sont syntaxiquement incorrectes ! -----------------\n");
                printf("\t------------------------------ Echec a l'analyse syntaxique -----------------------------------\n");
        }
        else{
                printf("\t--------------------------------- Succes a l'analyse syntaxique ! ------------------------------------\n");
        }
        return EXIT_SUCCESS;
}
void yyerror(char *s) {
        fprintf(stderr, "Erreur de syntaxe a la ligne %d: %s\n", lineno, s);
}
