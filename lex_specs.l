
%{

// need header for the call to exit() in lex.yy.c.
#include <stdlib.h>
#include <io.h>
#include <stdio.h>
#include <string.h>
#include "grammar_specs.tab.h"

#define isatty	_isatty
#define fileno	_fileno

void SkipAllTokensInLine();

%}

%option yylineno

DIGIT						[0-9]
ID							[a-zA-Z_][a-zA-Z_0-9]*

%%

"SET"						return TOKEN_SET;
"GET"						return TOKEN_GET;
=							return yytext[0];
"ADD"						return TOKEN_ADDITION;
"SUB"						return TOKEN_SUBTRACTION;
"EXIT"						return TOKEN_EXIT;
{ID}						{
								// It is important to set the yylval union here
								// for tokens which are associated with a union 
								// field. After setting the appropriate yylval
								// field, bison will later pass yylval as the 
								// token semantic value in the production rule
								// (i.e. as a $n value).
								//
								// For reason why we set yylval.id = strdup(yytext), 
								// See Bison Documentation :
								// 4.6.2 Semantic Values of Tokens
								yylval.id = _strdup(yytext);
								return TOKEN_IDENTIFIER;
							}

(-)?{DIGIT}+				{
								// It is important to set the yylval union here
								// for tokens which are associated with a union 
								// field. After setting the appropriate yylval
								// field, bison will later pass yylval as the 
								// token semantic value in the production rule
								// (i.e. as a $n value).
								//
								yylval.num = atoi(yytext);
								return TOKEN_INTEGER;
							}

[ \t]						;

\n							{ return yytext[0]; }

,							{ return yytext[0]; }

"//".*                      { 
								/* 
								Single Line Comment Processing.
								The regular expression associated with this rule means : 
								on encountering a token that begins with "//" followed by 
								zero or more characters except '\n'.
								*/			
								/* Do nothing. Just consume comment */ 
							}

"##".*                      { 
								/*
								Another Single Line Comment Processing.
								The regular expression associated with this rule means :
								on encountering a token that begins with "##" followed by 
								zero or more characters except '\n'.
								*/
								/* Do nothing. Just consume comment */ 
							}

.							{ 
								printf("Unexpected Text [%s].\n", yytext);
								exit(EXIT_FAILURE);
							}

%%

int yywrap(void)
{
	return 1;
}

void SkipAllTokensInLine()
{
	while (yylex() != '\n');
}


