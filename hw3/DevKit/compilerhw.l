%{
#include <stdlib.h>
#include "compilerhw.h"
%}
%%

[0-9]+(\.[0-9]+)?	{ yylval.dval = atof(yytext); return(NUMBER); }
[ \t]				;  /* Ignore whitespace */
[A-Za-z][A-Za-z0-9]*	{
    struct symtab *sp = symlook(yytext); 
    yylval.symp = sp; 
    if(sp->funcptr) { /* is it a function? */ 
        return FUNC; 
    } else {
        return NAME;
    }
}
"$"					{ return 0; /* end of input */ }
\n					{ /* Ignore newlines */ }
.					{ return yytext[0]; }
sqrt				return SQRT;
exp					return EXP;
log					return LOG;

%%
struct symtab {
    char *name;
    double (*funcptr)();
    double value;
} symtab[NSYMS];

void addfunc(char *name, double(*func)()) {
    struct symtab *sp = symlook(name);
    sp->funcptr = func;
}

int main() { 
    extern double sqrt(), exp(), log(); 
    addfunc("sqrt", sqrt); 
    addfunc("exp", exp); 
    addfunc("log", log); 
    
    yyparse(); 
    return 0;
}
