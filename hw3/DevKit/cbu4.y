%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG   0

#define MAXSYM      100
#define MAXSYMLEN   20
#define MAXTSYMLEN  15
#define MAXTSYMBOL  MAXSYM/2

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

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
void codegen(Node* );
void prtcode(int, int);

void dwgen();
int gentemp();
void assgnstmt(int, int);
void numassgn(int, int);
void addstmt(int, int, int);
void substmt(int, int, int);
void mulstmt(int, int, int);
void divstmt(int, int, int);
int insertsym(char *);
void ifstmt(Node*, Node*, Node*);
void whilestmt(Node*, Node*);
void funcdef(int, Node*, Node*);
void returnstmt(Node*);
%}

%token ADD SUB MUL DIV ASSGN ID NUM STMTEND START END IF ELSE WHILE FUNC RETURN

%type <node> stmt expr stmt_list program

%%

program: stmt_list { dwgen(); }
       ;

stmt_list: stmt_list stmt { $$ = MakeListTree($1, $2); }
         | stmt { $$ = $1; }
         ;

stmt: ID ASSGN expr STMTEND { assgnstmt($1->tokenval, $3->tokenval); }
    | ID ASSGN NUM STMTEND { numassgn($1->tokenval, $3); }
    | IF expr stmt_list ELSE stmt_list { ifstmt($2, $3, $5); }
    | WHILE expr stmt_list { whilestmt($2, $3); }
    | FUNC ID '(' ')' stmt_list RETURN expr STMTEND { funcdef($2->tokenval, $5, $7); }
    ;

expr: expr ADD expr { $$ = MakeOPTree(ADD, $1, $3); addstmt($1->tokenval, $3->tokenval, $$->tokenval); }
    | expr SUB expr { $$ = MakeOPTree(SUB, $1, $3); substmt($1->tokenval, $3->tokenval, $$->tokenval); }
    | expr MUL expr { $$ = MakeOPTree(MUL, $1, $3); mulstmt($1->tokenval, $3->tokenval, $$->tokenval); }
    | expr DIV expr { $$ = MakeOPTree(DIV, $1, $3); divstmt($1->tokenval, $3->tokenval, $$->tokenval); }
    | NUM { $$ = $1; }
    | ID { $$ = $1; }
    ;

%%

Node* MakeNode(int token, int operand) {
    Node * newnode;
    newnode = (Node *) malloc(sizeof (Node));
    newnode->token = token;
    newnode->tokenval = operand; 
    newnode->son = newnode->brother = NULL;
    return newnode;
}

Node* MakeOPTree(int token, Node *left, Node *right) {
    Node * newnode;
    newnode = (Node *) malloc(sizeof (Node));
    newnode->token = token;
    newnode->son = left;
    newnode->son->brother = right;
    return newnode;
}

Node* MakeListTree(Node* operand1, Node* operand2) {
    Node * newnode;
    Node * node;
    if (operand1 == NULL) {
        newnode = (Node *)malloc(sizeof (Node));
        newnode->token = newnode-> tokenval = STMTLIST;
        newnode->son = operand2;
        newnode->brother = NULL;
        return newnode;
    } else {
        node = operand1->son;
        while (node->brother != NULL) node = node->brother;
        node->brother = operand2;
        return operand1;
    }
}

void codegen(Node * root) {
    DFSTree(root);
}

void DFSTree(Node * n) {
    if (n==NULL) return;
    DFSTree(n->son);
    prtcode(n->token, n->tokenval);
    DFSTree(n->brother);
}

void prtcode(int token, int val) {
    switch (token) {
        case ID:
            fprintf(fp,"RVALUE %s\n", symtbl[val]);
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
        case ASSGN:
            fprintf(fp, ":=\n");
            break;
        case STMTLIST:
        default:
            break;
    }
}

void dwgen() {
    int i;
    fprintf(fp, "HALT\n");
    fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");
    for(i=0; i<maxsym; i++) {
        fprintf(fp, "DW %s\n", symtbl[i]);
    }
    fprintf(fp, "END\n");
}

int insertsym(char *s) {
    int i;
    for (i = 0; i < maxsym; i++) {
        if (strcmp(s, symtbl[i]) == 0) return i;
    }
    if (i < MAXSYM - 1) {
        strcpy(symtbl[maxsym], s);
        maxsym++;
        return maxsym - 1;
    } else {
        printf("symbol table overflow\n");
    }
    return 0;
}

void assgnstmt(int id, int expr) {
    fprintf(fp, "LVALUE %s\n", symtbl[id]);
    fprintf(fp, "RVALUE %d\n", expr);
    fprintf(fp, ":=\n");
}

void numassgn(int id, int num) {
    fprintf(fp, "LVALUE %s\n", symtbl[id]);
    fprintf(fp, "PUSH %d\n", num);
    fprintf(fp, ":=\n");
}

void addstmt(int left, int right, int result) {
    fprintf(fp, "RVALUE %s\n", symtbl[left]);
    fprintf(fp, "RVALUE %s\n", symtbl[right]);
    fprintf(fp, "+\n");
}

void substmt(int left, int right, int result) {
    fprintf(fp, "RVALUE %s\n", symtbl[left]);
    fprintf(fp, "RVALUE %s\n", symtbl[right]);
    fprintf(fp, "-\n");
}

void mulstmt(int left, int right, int result) {
    fprintf(fp, "RVALUE %s\n", symtbl[left]);
    fprintf(fp, "RVALUE %s\n", symtbl[right]);
    fprintf(fp, "*\n");
}

void divstmt(int left, int right, int result) {
    fprintf(fp, "RVALUE %s\n", symtbl[left]);
    fprintf(fp, "RVALUE %s\n", symtbl[right]);
    fprintf(fp, "/\n");
}

void ifstmt(Node *cond, Node *if_block, Node *else_block) {
    int else_label = gentemp();
    int end_label = gentemp();

    fprintf(fp, "RVALUE %d\n", cond->tokenval);
    fprintf(fp, "JZ %d\n", else_label);
    DFSTree(if_block);
    fprintf(fp, "JMP %d\n", end_label);
    fprintf(fp, "LABEL %d\n", else_label);
    DFSTree(else_block);
    fprintf(fp, "LABEL %d\n", end_label);
}

void whilestmt(Node *cond, Node *body) {
    int start_label = gentemp();
    int end_label = gentemp();

    fprintf(fp, "LABEL %d\n", start_label);
    fprintf(fp, "RVALUE %d\n", cond->tokenval);
    fprintf(fp, "JZ %d\n", end_label);
    DFSTree(body);
    fprintf(fp, "JMP %d\n", start_label);
    fprintf(fp, "LABEL %d\n", end_label);
}

void funcdef(int id, Node *body, Node *ret_expr) {
    fprintf(fp, "FUNC %s\n", symtbl[id]);
    DFSTree(body);
    fprintf(fp, "RVALUE %d\n", ret_expr->tokenval);
    fprintf(fp, "RET\n");
}

void returnstmt(Node *expr) {
    fprintf(fp, "RVALUE %d\n", expr->tokenval);
    fprintf(fp, "RET\n");
}

int gentemp() {
    static int label = 0;
    return label++;
}
