%{
#include "compilerhw.h"
#include <stdio.h>
#include <string.h>
%}
%union {
    double dval;
    struct symtab *symp;
}
%token <symp> NAME FUNC
%token <dval> NUMBER
%token SQRT LOG EXP
%type <dval> Fact Term Exp

%left '+' '-'
%left '*' '/'
%right '^'
%nonassoc UMINUS

%%
StmtList: StmtList Stmt '\n'
        | Stmt '\n'
        ;
Stmt: NAME '=' Exp  { $1->value = $3; }
    | Exp           { printf("=%f\n", $1); }
    ;
Exp: Exp '+' Exp   { $$ = $1 + $3; }
    | Exp '-' Exp   { $$ = $1 - $3; }
    | Exp '*' Exp   { $$ = $1 * $3; }
    | Exp '/' Exp   { $$ = $1 / $3; }
    | Exp '^' Exp   { $$ = pow($1, $3); }
    | '(' Exp ')'   { $$ = $2; }
    | '-' Exp %prec UMINUS { $$ = -$2; }
    | Fact          { $$ = $1; }
    ;
Fact: NUMBER        { $$ = $1; }
    | NAME          { $$ = $1->value; }
    | FUNC '(' Exp ')' { $$ = $1->funcptr($3); }
    ;
%%
void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
}
