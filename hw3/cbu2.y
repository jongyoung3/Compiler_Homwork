%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2

#define STMTLIST 500

typedef struct nodeType {
	int token;
    int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	} Node;

#define YYSTYPE Node*
	
int tsymbolcnt=0;
int errorcnt=0;
int looplabel = 0;
int label = 0;
int loop = 0;
int one = 1;
int ifcount = 0;
int arraysize;
int arrayname;
int labeloutnum = 0;
int labelout = 1;
int stringval;
int arraylist[MAXSYM] = { 0 };
int arraysizelist[MAXSYM] = { 0 };

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern char chartbl[MAXTSYMBOL][MAXTSYMLEN];
extern int maxsym;
extern int lineno;
extern int maxchar;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
void codegen(Node* );
void prtcode(int, int);

void	dwgen();
int	gentemp();
void	assignstmt(int, int);
void	numassign(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
void	mulstmt(int, int, int);
void	divstmt(int, int, int);
int		insertsym(char *);
%}

%token	ADD SUB ASSIGN ID NUM FNUM STMTEND START END ID2 ID3 INT CHAR CHARVAL DIV MUL
%token	ADDONE SUBONE PLUSASSIGN MINUSASSIGN MULASSIGN DIVASSIGN STRINGASSIGN STRINGARRAY PRINTSTRING STRINGNAME
%token	OPENARRAY CLOSEARRAY  DEFARRAY ARRAYSIZE ARRAYNAME ARRAYNAME2 DEFARRAYNAME DEFSTRING
%token	EQUAL NOTEQUAL GREAT LESS LESSEQUAL GREATEQUAL
%token	IF ELSE STARTSTMT ENDSTMT STARTCONT ENDCONT WHILE EIF IFELSE LOOPSTART LOOPSTMT WHILESTMT
%token FOR FORSTART FORINITSTMT FORSTMT 
 


%%
program	: START stmt_list END	{ if (errorcnt==0) {codegen($2); dwgen();} }
		;

stmt_list 	: 	stmt_list stmt 	{$$=MakeListTree($1, $2);}
			|	stmt			{$$=MakeListTree(NULL, $1);}
			| 	error STMTEND	{ errorcnt++; yyerrok;}
			;

stmt	:	stmt_control
		|	stmt_banbok
		|	stmt_decl
		|	arraydef
		|	string_print
		;

stmt_control	: IF STARTCONT bigyo_expr ENDCONT STARTSTMT stmt_list ENDSTMT {$$=MakeOPTree(IF,$3,$6);}
				| stmt_eif_if ELSE STARTSTMT stmt_list ENDSTMT  {$$=MakeOPTree(IF,$1,$4);}
				;
				
stmt_eif_if :	IF STARTCONT bigyo_expr ENDCONT STARTSTMT stmt_list ENDSTMT {$$=MakeOPTree(IFELSE,$3,$6);}
			;


stmt_banbok : stmt_while
			| stmt_for
			;


stmt_while		:	 loopstart loopstmt {$$=MakeOPTree(WHILESTMT,$1,$2);}	
				;	


loopstart	:	WHILE {$$=MakeNode(LOOPSTART,NULL);}
			;

loopstmt 	:	STARTCONT bigyo_expr ENDCONT STARTSTMT stmt_list ENDSTMT {$$=MakeOPTree(LOOPSTMT,$2,$5);}
			;

stmt_for	:  for_start for_loopstmt {$$=MakeOPTree(FORSTMT,$1,$2);}
			;

for_start : for_init  bigyo_expr STMTEND {$$=MakeOPTree(FORSTART,$1,$2);}
		  ;

for_init : for_loop_start STARTCONT stmt_decl { $$=MakeOPTree(FORINITSTMT,$3,$1);}
		 ;

for_loop_start : FOR {$$=MakeNode(LOOPSTART,NULL);}
			   ;

for_loopstmt : stmt_decl ENDCONT STARTSTMT stmt_list ENDSTMT {$$=MakeOPTree(LOOPSTMT,$4,$1);}
			 ;

stmt_decl	:	type ID ASSIGN sansul_expr STMTEND { $2->token = ID2; $$=MakeOPTree(ASSIGN, $2, $4);}
			|	type ID PLUSASSIGN sansul_expr STMTEND { $2->token = ID3; $$=MakeOPTree(PLUSASSIGN, $2, $4);}
			|	type ID MINUSASSIGN sansul_expr STMTEND { $2->token = ID3; $$=MakeOPTree(MINUSASSIGN, $2, $4);}
			|	type ID MULASSIGN sansul_expr STMTEND { $2->token = ID3; $$=MakeOPTree(MULASSIGN, $2, $4);}
			|	type ID DIVASSIGN sansul_expr STMTEND { $2->token = ID3; $$=MakeOPTree(DIVASSIGN, $2, $4);}
			|	ID ASSIGN sansul_expr STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSIGN, $1, $3);}
			|	ID PLUSASSIGN sansul_expr STMTEND {$1->token = ID3; $$=MakeOPTree(PLUSASSIGN, $1, $3);}
			|	ID MINUSASSIGN sansul_expr STMTEND {$1->token = ID3; $$=MakeOPTree(MINUSASSIGN, $1, $3);}
			|	ID MULASSIGN sansul_expr STMTEND {$1->token = ID3; $$=MakeOPTree(MULASSIGN, $1, $3);}
			|	ID DIVASSIGN sansul_expr STMTEND {$1->token = ID3; $$=MakeOPTree(DIVASSIGN, $1, $3);}
			|	arrayassign2 ASSIGN sansul_expr STMTEND{$$=MakeOPTree(ASSIGN,$1,$3);}
			|	onepm_expr
			|	bigyo_expr
			;


arraydef : intarraydef
		 | stringdef
		 ;

intarraydef	:	type ID OPENARRAY NUM CLOSEARRAY STMTEND {$2->token = DEFARRAYNAME; $4->token = ARRAYSIZE; $$=MakeOPTree(DEFARRAY,$2,$4);}
			;

stringdef	: string_name string_value {$$=MakeOPTree(DEFSTRING,$1,$2);}
			;

string_name	: 	type  OPENARRAY NUM CLOSEARRAY ID { $3->token = ARRAYSIZE; $5->token = DEFARRAYNAME; $$=MakeOPTree(DEFARRAY,$5,$3);}
			;

string_value	:	ASSIGN CHARVAL STMTEND {$$=MakeOPTree(STRINGASSIGN,$2,NULL);}
				;

type	:	INT
		|	CHAR
		;

arrayassign		:	ID OPENARRAY NUM CLOSEARRAY {$1->token = ARRAYNAME2; $$=MakeOPTree(ADD,$1,$3);}
				|	ID OPENARRAY ID CLOSEARRAY {$1->token = ARRAYNAME;  $$=MakeOPTree(ADD,$1,$3);}
				;


arrayassign2	:	ID OPENARRAY NUM CLOSEARRAY {$1->token = ARRAYNAME; $$=MakeOPTree(ADD,$1,$3);}
				|	ID OPENARRAY ID CLOSEARRAY {$1->token = ARRAYNAME;  $$=MakeOPTree(ADD,$1,$3);}
				;

string_print	:	PRINTSTRING STARTCONT ID ENDCONT STMTEND {$3->token = STRINGNAME; $$=MakeOPTree(PRINTSTRING,$3,NULL);}
				;

onepm_expr	: ID ADDONE STMTEND {$1->token = ID3; $$=MakeOPTree(ADDONE,$1,NULL);}
			| ID SUBONE STMTEND {$1->token = ID3; $$=MakeOPTree(SUBONE,$1,NULL);}
			;			

bigyo_expr	: bigyo_expr EQUAL sansul_expr {$$=MakeOPTree(EQUAL,$1,$3);}
			| bigyo_expr NOTEQUAL sansul_expr {$$=MakeOPTree(NOTEQUAL,$1,$3);}
			| bigyo_expr GREAT sansul_expr {$$=MakeOPTree(GREAT,$1,$3);}
			| bigyo_expr LESS sansul_expr {$$=MakeOPTree(LESS,$1,$3);}
			| bigyo_expr GREATEQUAL sansul_expr {$$=MakeOPTree(GREATEQUAL,$1,$3);}
			| bigyo_expr LESSEQUAL sansul_expr {$$=MakeOPTree(LESSEQUAL,$1,$3);}
			| sansul_expr
			;			

sansul_expr	: 	sansul_expr ADD sansul_expr_two	{ $$=MakeOPTree(ADD, $1, $3); }
			|	sansul_expr SUB sansul_expr_two	{ $$=MakeOPTree(SUB, $1, $3); }
			|	sansul_expr_two
			;

sansul_expr_two :	sansul_expr_two MUL term 	{ $$=MakeOPTree(MUL, $1, $3); }
				|	sansul_expr_two DIV term	{ $$=MakeOPTree(DIV, $1, $3); }
				|	term 
				;

term	:	NUM		{ /* NUM node is created in lex */ }
		|	ID		{ /* ID node is created in lex */}
		|	arrayassign
		;


%%
int main(int argc, char *argv[]) 
{
	printf("\nHAYONG LANGUAGE COMPILER\n");
	printf("(C) Copyright by Ha Yong Jeong (moonlighthouse99@gmail.com), 2023.\n");
	
	if (argc == 2)
		yyin = fopen(argv[1], "r");
	else {
		printf("Usage: cbu2 inputfile\noutput file is 'a.asm'\n");

		return(0);
		}
		
	fp=fopen("a.asm", "w");
	
	yyparse();
	
	fclose(yyin);
	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}


Node * MakeOPTree(int op, Node* operand1, Node* operand2)
{
	Node * newnode;

	newnode = (Node *)malloc(sizeof (Node));
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	return newnode;
}

Node * MakeNode(int token, int operand)
{
	Node * newnode;

	newnode = (Node *) malloc(sizeof (Node));
	newnode->token = token;
	newnode->tokenval = operand;
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node * MakeListTree(Node* operand1, Node* operand2)
{
	Node * newnode;
	Node * node;

	if (operand1 == NULL){
		newnode = (Node *)malloc(sizeof (Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
		while (node->brother != NULL) node = node->brother;
		node->brother = operand2;
		return operand1;
		}
}

void codegen(Node * root)
{
	DFSTree(root);
}

void DFSTree(Node * n)
{
	if (n==NULL) return;
	DFSTree(n->son);
	prtcode(n->token, n->tokenval);
	DFSTree(n->brother);
	
}

void prtcode(int token, int val)
{
	switch (token) {
	case ID:
		fprintf(fp,"RVALUE %s\n", symtbl[val]);
		break;
	case ID2:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		break;
	case ID3:
		fprintf(fp, "LVALUE %s\n", symtbl[val]);
		fprintf(fp, "RVALUE %s\n", symtbl[val]);
		break;
	case CHARVAL:
		strcpy(chartbl[val],strtok(chartbl[val], "'"));
		stringval = val;
		break;
	case STRINGASSIGN:
		for(int i = 0; i < arraysize; i++)
		{
			fprintf(fp, "LVALUE array%s%d\n",symtbl[arrayname],i);
			if (chartbl[stringval][i] == '\0') break;
			fprintf(fp, "PUSH %d\n", chartbl[stringval][i]);
			fprintf(fp, ":=\n");
		}
		break;
	case ARRAYNAME:
		fprintf(fp, "LVALUE array%s0\n", symtbl[val]); 
		break;
	case ARRAYNAME2:
		fprintf(fp, "RVALUE array%s0\n", symtbl[arrayname]);
		break;
	case DEFARRAYNAME:
		arraylist[val] = 1;
		arrayname = val;
		break;
	case ARRAYSIZE:
		arraysize = val;
		break;
	case DEFARRAY:
		for(int i =0; i < arraysize; i++)
		{
			fprintf(fp, "DW array%s%d\n",symtbl[arrayname],i);
		}
		arraysizelist[arrayname] = arraysize;
		break;
	case STRINGNAME:
		for(int i = 0; i < arraysizelist[val]; i++)
		{
			fprintf(fp, "RVALUE array%s%d\n",symtbl[val],i);
			fprintf(fp, "OUTCH\n");
		}
		break;
	case NUM:
		fprintf(fp, "PUSH %d\n", val);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
	case MUL:
		fprintf(fp, "*\n");
		break;
	case DIV:
		fprintf(fp, "/\n");
		break;
	case ADDONE:
		fprintf(fp, "PUSH %d\n", one);
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
		break;
	case SUBONE:
		fprintf(fp, "PUSH %d\n", one);
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
		break;
	case ASSIGN:
		fprintf(fp, ":=\n");
		break;
	case PLUSASSIGN:
		fprintf(fp, "+\n");
		fprintf(fp, ":=\n");
		break;
	case MINUSASSIGN:
		fprintf(fp, "-\n");
		fprintf(fp, ":=\n");
		break;
	case MULASSIGN:
		fprintf(fp, "*\n");
		fprintf(fp, ":=\n");
		break;
	case DIVASSIGN:
		fprintf(fp, "/\n");
		fprintf(fp, ":=\n");
		break;
	case EQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOFALSE label%d\n", label);
		labelout = 1;
		break;
	case GREATEQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS label%d\n", label);
		labelout = 1;
		break;
	case GREAT:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS label%d\n", label);
		fprintf(fp, "GOTO labelout%d\n", labeloutnum);
		fprintf(fp, "LABEL label%d\n", label);
		label++;
		labelout = -1;
		break;
	case LESSEQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS label%d\n", label);
		labelout = 1;
		break;
	case LESS:
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS label%d\n", label);
		fprintf(fp, "GOTO labelout%d\n", labeloutnum);
		fprintf(fp, "LABEL label%d\n", label);
		label++;
		labelout = -1;
		break;
	case NOTEQUAL:
		fprintf(fp, "-\n");
		fprintf(fp, "GOTRUE label%d\n", label);
		labelout = 1;
		break;
	case IF:
		if(labelout == -1)
		{
			fprintf(fp,"LABEL labelout%d\n",labeloutnum);
			labeloutnum++;
		}
		else
		{
			fprintf(fp,"LABEL label%d\n",label);
			label++;
		}
		break;
	case IFELSE:
		if(labelout == -1)
		{
			fprintf(fp,"LABEL labelout%d\n",labeloutnum);
			labeloutnum++;
		}
		else
		{
			fprintf(fp,"LABEL label%d\n",label);
			label++;
		}
		break;
	case LOOPSTART:
		fprintf(fp,"LABEL loop%d\n",looplabel);
		break;
	case LOOPSTMT:
		fprintf(fp,"GOTO loop%d\n",looplabel);
		looplabel++;
		if(labelout == -1)
		{
			fprintf(fp,"LABEL labelout%d\n",labeloutnum);
			labeloutnum++;
		}
		else
		{
			fprintf(fp,"LABEL label%d\n",label);
			label++;
		}
		break;
	case STMTLIST:
		break;
	default:
		break;
	};
}


/*
int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}
*/
void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++)
	{
		if(arraylist[i] == 0)
			fprintf(fp, "DW %s\n", symtbl[i]);
	}
		
	fprintf(fp, "END\n");
}

