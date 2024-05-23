%{
#include <string.h>
#include <stdlib.h>
#include "cbu2.h"
#define MAXSYM	100
#define	MAXSYMLEN	20
char symtbl[MAXSYM][MAXSYMLEN];
char chartbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym();
int maxsym=0;
int maxchar=0;
char s[MAXSYMLEN];
int temp;

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
hletter	[\xb0-\xfe][\xa0-\xfe]
letter	({eletter}|{hletter})
digit	-?[0-9]
id		{letter}({letter}|{digit})*
char \'{id}\'
%%
int {return(INT);}
정수 {return(INT);}
float {return(FLOAT);}
실수 {return(FLOAT);}
char {return(CHAR);}
문자 {return(CHAR);}
{ws}	{/* do nothing */}
{nl}	{lineno++; }
플러스 {return(ADD); }
"+" {return(ADD);}
마이너스 {return(SUB); }
"-" {return(SUB);}
스타 {return(MUL);}
"*" {return(MUL);}
디바이드 {return(DIV);}
"/" {return(DIV);}
플러스플러스 {return(ADDONE);}
"++" {return(ADDONE);}
마이너스마이너스 {return(SUBONE);}
"--" {return(SUBONE);}
플러스하고갱신 {return(PLUSASSIGN);}
"+=" {return(PLUSASSIGN);}
마이너스하고갱신 {return(MINUSASSIGN);}
"-=" {return(MINUSASSIGN);}
스타하고갱신 {return(MULASSIGN);}
"*=" {return(MULASSIGN);}
디바이드갱신 {return(DIVASSIGN);}
"/=" {return(DIVASSIGN);}
같은지확인 {return(EQUAL);}
"==" {return(EQUAL);}
안같은지확인 {return(NOTEQUAL);}
"!=" {return(NOTEQUAL);}
더큼\? {return(GREAT);}
">" {return(GREAT);}
더작음\? {return(LESS);}
"<" {return(LESS);}
이거포함더큼\? {return(GREATEQUAL);}
">=" {return(GREATEQUAL);}
이거포함더작음\? {return(LESSEQUAL);}
"<=" {return(LESSEQUAL);}
만약 {return(IF);}
if {return(IF);}
만약아니면 {return(ELSE);}
else {return(ELSE);}
"(" {return(STARTCONT);}
")" {return(ENDCONT);}
"{" {return(STARTSTMT);}
"}" {return(ENDSTMT);}
와일반복 {return(WHILE);}
while {return(WHILE);}
포반복 {return(FOR);}
for {return(FOR);}
"[" {return(OPENARRAY);}
"]" {return(CLOSEARRAY);}
printstring {return(PRINTSTRING);}
"=" {return(ASSIGN);}
:=		{return(ASSIGN); }
할당 {return(ASSIGN); }
;		{return(STMTEND); }
시작		{return(START); }
gogo		{return(START); }
끝		{return(END); }
finishend		{return(END); }
{char} {temp=insertchar(yytext); yylval=MakeNode(CHARVAL, temp); return(CHARVAL);}
{id}	{temp=insertsym(yytext); yylval=MakeNode(ID, temp); return(ID);}
{digit}+ {sscanf(yytext, "%d", &temp); yylval=MakeNode(NUM, temp); return(NUM);}
.			{printf("invalid token %s\n", yytext); }
%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

int insertchar(s)
char *s;
{
int i;
	
	for(i=0;i<maxchar; i++) {
		if(strcmp(s, chartbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(chartbl[maxchar],s);
		maxchar++;
		return(maxchar-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}