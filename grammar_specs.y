
%{

#define YYDEBUG 1 

// Useful links :
// Part 01: Tutorial on lex/yacc
// https://www.youtube.com/watch?v=54bo1qaHAfk
// 
// Part 02: Tutorial on lex/yacc.
// https://www.youtube.com/watch?v=__-wUHG2rfM
//
// Programming: bison and flex nice to know (read description)
// https://www.youtube.com/watch?v=xFN9txVKhUs&feature=youtu.be
//
// How to use “literal string tokens” in Bison
// https://stackoverflow.com/questions/43095501/how-to-use-literal-string-tokens-in-bison
//

// These parts will get copied directly into Bison's output file.

void yyerror(char* s);
#include <stdio.h>
#include <stdlib.h>

extern int symbolVal(char* symbol, int* pValueReceiver);
extern int updateSymbolVal(char* symbol, int val);
extern int yylineno;
extern char* yytext;
extern int yylex();

%}

%locations

/* 
The following %error-verbose option is v useful.
It allows the display of descriptive error messages.
*/
%error-verbose 

%token-table

/* 
A %union will be used to contain the semantic meaning of tokens
and non-terminals.

(see Bison documentation section 1.3 Semantic Values)

A global variable named yylval will be defined based on this %union.

This union is what gets returned to the Parser from the Scanner. 
*/
%union 
{
	int num; 
	char* id;
} 

/* 
%tokens associated with a %union field are "Terminal Symbol" tokens. 
These tokens can have multiple (infinite even) lexeme expressions.
E.g. :
TOKEN_INTEGER can be expressed as 0, 1, 21, 39991, -27, etc.
TOKEN_IDENTIFIER can be "a", "MyVar", "returnVal", etc.

They are said to have Semantic Values. Hence using our example above,
the integer value 21 is an example of a semantic value of TOKEN_INTEGER.
In other words, it is an instance of an INTEGER token.

The string "MyVar" is an example of a semantic value of TOKEN_IDENTIFIER.
Similarly, "MyVar" is an instance of an IDENTIFIER token.

One thing to note is that, of course, an integer is not the same as
an identifier. Hence it is important to assciate semantic values 
with specific fields of the %union, e.g. TOKEN_INTEGER with the <num>
field and TOKEN_IDENTIFIER with the <id> field.
*/
%token <num>	TOKEN_INTEGER
%token <id>		TOKEN_IDENTIFIER

/*	
The non-terminals that have semantic values must also be associated 
with a field of the %union.

A non-terminal that can appear on the right side of a production
rule may have semantic value.

E.g. :
expr -> expr + number
...
number -> identifier
			|
		  integer

Here, the non-terminal "number" appears on the RHS of the production rule for "expr"
hence it must have a semantic value. This is because in order to evaluate expr, 
number must evaluate to something.

However, note that a non-terminal is by nature not a token. Therefore, we
do not associate a non-terminal with a %token declaration but a %type declaration.

The %type declaration associates the non-terminal with a field of the %union.
*/
/*
Here, we declare that the non-terminal "numeric_value" has semantic value associated
with the "num" field of the %union. This means that "numeric_value" must eventually
evaluate to an integer value.
*/
%type <num>		numeric_value 

// TOKEN_COMMA and TOKEN_NEWLINE are not necessary.
// But if declared as %token definitions, they will 
// be defined in the yytokentype enum (grammar_specs.tab.h). 
// That is, they will be assigned a number each.
//
// These are the numbers that the rules for the comma
// and newline regular expressions can use to return in lex_specs.l.
// If used in lex_specs.l in this way, the rules in grammar_specs.y
// must use TOKEN_COMMA and TOKEN_NEWLINE instead of directly
// using ',' and '\n'.
// 
/*
%token TOKEN_COMMA 
%token TOKEN_NEWLINE  
*/

/* 
The following are tokens which are not associated with a %union field.
These %token declarations will cause Bison to generate enum values
in the yytokentype enum (grammar_specs.tab.h).

They are each not associated with a %union field because they are 
terminal symbols that do not hold any semantic values (see Bison
documentation section 1.3 Semantic Values). They are constant-string 
tokens that will not take on any other string values.

E.g. TOKEN_SET will always represent the token "SET".
TOKEN_GET will always represent the token "GET", etc.

Tokens which have no semantic values are usually keywords of a language.

A token which can have semantic value is TOKEN_INTEGER (a terminal).
This is because a TOKEN_INTEGER can be any integer e.g. 0, 1, 2, 1000, 3918, etc.
*/
%token TOKEN_SET
%token TOKEN_GET
%token TOKEN_ADDITION
%token TOKEN_SUBTRACTION
%token TOKEN_EXIT

%%

%start lines;

lines	: line						{ printf("Rule lines : line\n");}
		| lines line				{ printf("Rule lines : lines line\n");}
		;

line	: '\n'						{ printf("Rule line : \\n\n");}
		| set	'\n'				{ printf("Rule line : set\n");}
		| get	'\n'				{ printf("Rule line : get\n");}
		| add	'\n'				{ printf("Rule line : add\n");}
		| sub	'\n'				{ printf("Rule line : sub");}
		| TOKEN_EXIT '\n'			{ exit(EXIT_SUCCESS); }
		;

set		: TOKEN_SET TOKEN_IDENTIFIER '=' numeric_value	{
																	printf("Rule set\n");

																	if (updateSymbolVal($2, $4) == 1)
																	{
																	}
																	else
																	{
																		printf("SET failed.\n");																	
																		exit(EXIT_FAILURE);
																	}
																	// After using yylval.id, feee it.
																	free($2);
																}
		;

get		: TOKEN_GET TOKEN_IDENTIFIER							{
																	printf("Rule get\n");

																	int iVal = 0;
																	if (symbolVal($2, &iVal) == 1)
																	{
																		printf ("Value of [%s] : [%d]\n", $2, iVal);
																	}
																	else
																	{
																		printf ("GET failed.\n");
																	}
																	// After using yylval.id, feee it.
																	free($2);																	
																}
		;

add		: TOKEN_ADDITION TOKEN_IDENTIFIER ',' numeric_value		{
																			printf("Rule add\n");

																			int iVal = 0;
																			if (symbolVal($2, &iVal) == 1)
																			{
																				if (updateSymbolVal($2, iVal + $4) == 1)
																				{
																				}
																				else
																				{
																					printf("ADD failed.\n");
																					exit(EXIT_FAILURE);
																				}
																			}
																			else
																			{
																				printf ("Variable [%s] does not exist.\n", $2);
																			}
																			// After using yylval.id, feee it.
																			free($2);
																		}
		;

sub		: TOKEN_SUBTRACTION TOKEN_IDENTIFIER ',' numeric_value	{
																			printf("Rule sub\n");

																			int iVal = 0;
																			if (symbolVal($2, &iVal) == 1)
																			{
																				if (updateSymbolVal($2, iVal - $4) == 1)
																				{
																				}
																				else
																				{
																					printf("SUB failed.\n");
																					exit(EXIT_FAILURE);
																				}
																			}
																			else
																			{
																				printf ("Variable [%s] does not exist.\n", $2);
																			}
																			// After using yylval.id, feee it.
																			free($2);
																		}
		;

numeric_value	: TOKEN_IDENTIFIER	{
										printf("Rule numeric_value : TOKEN_IDENTIFIER\n");

										int iVal = 0;
										if (symbolVal($1, &iVal) == 1)
										{											
											printf ("Value of [%s] : [%d]\n", $1, iVal);
										}
										else
										{
											printf ("Variable [%s] does not exist.\n", $1);
											exit(EXIT_FAILURE);
										}
										free($1);
										$$ = iVal;
									}
				| TOKEN_INTEGER		{ 
										printf("Rule numeric_value : TOKEN_INTEGER\n");

										$$ = $1; 
									}
				;

%%

void yyerror(char* s)
{
	printf("%s\n", s);
}


