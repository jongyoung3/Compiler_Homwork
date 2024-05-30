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
jletter     [\x30-\x39\x41-\x5A\x61-\x7A\xA1-\xDF\xE0-\xEF][\x80-\xBF]
cletter     [\xE4-\xE9][\x80-\xBF][\x80-\xBF]
letter      ({eletter}|{hletter}|{jletter}|{cletter})
digit	-?[0-9]
id		{letter}({letter}|{digit})*
char \'{id}\'
%%
int {return(INT);}
정수 {return(INT);}
イント {return(INT);}
整数 {return(INT);}
char {return(CHAR);}
문자 {return(CHAR);}
文字 {return(CHAR);}
字符 {return(CHAR);}
{ws}	{/* do nothing */}
{nl}	{lineno++; }
플러스 {return(ADD); }
"+" {return(ADD);}
プラス {return(ADD);}
加法 {return(ADD);}
마이너스 {return(SUB); }
"-" {return(SUB);}
マイナス {return(SUB);}
减法 {return(SUB);}
스타 {return(MUL);}
"*" {return(MUL);}
乗算する {return(MUL);}
乘法 {return(MUL);}
디바이드 {return(DIV);}
"/" {return(DIV);}
分割する {return(DIV);}
除法 {return(DIV);}
플러스플러스 {return(ADDONE);}
"++" {return(ADDONE);}
増 {return(ADDONE);}
增加 {return(ADDONE);}
마이너스마이너스 {return(SUBONE);}
"--" {return(SUBONE);}
減少 {return(SUBONE);}
柿子 {return(SUBONE);}
플러스하고갱신 {return(PLUSASSIGN);}
"+=" {return(PLUSASSIGN);}
加算代入 {return(PLUSASSIGN);}
加赋值 {return(PLUSASSIGN);}
마이너스하고갱신 {return(MINUSASSIGN);}
"-=" {return(MINUSASSIGN);}
減算代入 {return(MINUSASSIGN);}
减赋值 {return(MINUSASSIGN);}
스타하고갱신 {return(MULASSIGN);}
"*=" {return(MULASSIGN);}
乗算代入 {return(MULASSIGN);}
乘赋值 {return(MULASSIGN);}
디바이드갱신 {return(DIVASSIGN);}
"/=" {return(DIVASSIGN);}
除算代入 {return(DIVASSIGN);}
除赋值 {return(DIVASSIGN);}
같은지확인 {return(EQUAL);}
"==" {return(EQUAL);}
等しい {return(EQUAL);}
等于 {return(EQUAL);}
안같은지확인 {return(NOTEQUAL);}
"!=" {return(NOTEQUAL);}
等しくない {return(NOTEQUAL);}
不等于 {return(NOTEQUAL);}
더큼\? {return(GREAT);}
">" {return(GREAT);}
より大きい\? {return(GREAT);}
大于\? {return(GREAT);}
더작음\? {return(LESS);}
"<" {return(LESS);}
より小さい\? {return(LESS);}
小于\? {return(LESS);}
이거포함더큼\? {return(GREATEQUAL);}
">=" {return(GREATEQUAL);}
以上\? {return(GREATEQUAL);}
大于等于\? {return(GREATEQUAL);}
이거포함더작음\? {return(LESSEQUAL);}
"<=" {return(LESSEQUAL);}
以下\? {return(LESSEQUAL);}
小于等于\? {return(LESSEQUAL);}
만약 {return(IF);}
if {return(IF);}
もし {return(IF);}
如果 {return(IF);}
만약아니면 {return(ELSE);}
else {return(ELSE);}
さもなければ {return(ELSE);}
否则 {return(ELSE);}
"(" {return(LEFTPTH);}
")" {return(RIGHTPTH);}
"{" {return(LEFTBRACE);}
"}" {return(RIGHTBRACE);}
"[" {return(LEFTSBKT);}
"]" {return(RIGHTSBKT);}
printstring {return(PRINTSTRING);}
"=" {return(ASSIGN);}
:=		{return(ASSIGN); }
할당 {return(ASSIGN); }
割り当て {return(ASSIGN); }
赋值 {return(ASSIGN); }
;		{return(STMTEND); }
시작		{return(START); }
gogo		{return(START); }
開始        {return(START); }
开始        {return(START); }
끝		{return(END); }
finishend		{return(END); }
終了      {return(END); }
结束        {return(END); }
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