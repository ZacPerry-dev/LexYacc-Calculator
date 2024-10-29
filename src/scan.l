%{
/* COSC: 561 - Compilers & Runtime Systems - Assignment 2: Cexpr 
 * Zachary Perry
 * 10/29/24
 * This Lex file will take the input and parse it into tokens for Yacc to use.
 * This includes letters, numbers, keywords like clear and dump, and the various supported operations.
 */
#include "y.tab.h"
%}
%%
[0-9]+    { sscanf(yytext, "%lld", &yylval.num);
            return NUM; }
[a-z]     { yylval.val = yytext[0] - 'a';
            return ID;  }
"clear"   { return CLEAR; }
"dump"    { return DUMP; }

"("       { return '('; }
")"       { return ')'; }
"~"       { return '~'; }
"*"       { return '*'; }
"/"       { return '/'; }
"%"       { return '%'; }
"+"       { return '+'; }
"-"       { return '-'; } 
"<<"      { return LSHIFT; }
">>"      { return RSHIFT; }
"&"       { return '&'; }
"^"       { return '^'; }
"|"       { return '|'; }
"="       { return '='; }
"+="      { return ASSIGNMENT_ADD_EQUAL; }
"-="      { return ASSIGNMENT_SUB_EQUAL; }
"*="      { return ASSIGNMENT_MULT_EQUAL; }
"/="      { return ASSIGNMENT_DIV_EQUAL; }
"%="      { return ASSIGNMENT_REM_EQUAL; }
"<<="     { return ASSIGNMENT_LSHIFT_EQUAL; }
">>="     { return ASSIGNMENT_RSHIFT_EQUAL; }
"&="      { return ASSIGNMENT_AND_EQUAL; }
"^="      { return ASSIGNMENT_XOR_EQUAL; }
"|="      { return ASSIGNMENT_OR_EQUAL; }
[ \t\n]   ; 
.         { return yytext[0]; }
