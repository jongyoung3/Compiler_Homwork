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
플플러스 {return(ADDONE);}
"++" {return(ADDONE);}
마마이너스 {return(SUBONE);}
"--" {return(SUBONE);}
플러스갱신 {return(PLUSASSIGN);}
"+=" {return(PLUSASSIGN);}
마이너스갱신 {return(MINUSASSIGN);}
"-=" {return(MINUSASSIGN);}
스타갱신 {return(MULASSIGN);}
"*=" {return(MULASSIGN);}
디바이드갱신 {return(DIVASSIGN);}
"/=" {return(DIVASSIGN);}
같은지확인 {return(EQUAL);}
"==" {return(EQUAL);}
않같은지확인 {return(NOTEQUAL);}
갈람가지\~ {return(NOTEQUAL);}
스읍\~ {return(NOTEQUAL);}
"!=" {return(NOTEQUAL);}
어우이거여\? {return(GREAT);}
">" {return(GREAT);}
이게다여\? {return(LESS);}
"<" {return(LESS);}
여까지여\? {return(GREATEQUAL);}
">=" {return(GREATEQUAL);}
여까지가다여\? {return(LESSEQUAL);}
"<=" {return(LESSEQUAL);}
그때볼껴\? {return(IF);}
if {return(IF);}
진짜볼껴\? {return(ELSE);}
else {return(ELSE);}
"(" {return(STARTCONT);}
")" {return(ENDCONT);}
"{" {return(STARTSTMT);}

"}" {return(ENDSTMT);}
다해써다해써어\~ {return(WHILE);}
while {return(WHILE);}
거의다해써어\~ {return(FOR);}
for {return(FOR);}
"[" {return(OPENARRAY);}
"]" {return(CLOSEARRAY);}
는 {return(ASSIGN);}
은 {return(ASSIGN);}
느어\~ {return(ASSIGN);}
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