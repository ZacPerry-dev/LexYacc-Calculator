/*
 * Zachary Perry
 * other stuff (todo)
 */

%{
#include <stdio.h>

// something to hold variables
#define VARS 26
int vars[VARS];
%}

/* UNION -> defines the possible types for tokens / values */
%union {
  int num;
  int var;
}

/* TOKEN -> declares a token type of numbers */
%token <num> NUM
%token <num> ID
%token CLEAR
%token DUMP
%token ASSIGNMENT_ADD_EQUAL 
%token ASSIGNMENT_SUB_EQUAL 
%token ASSIGNMENT_MULT_EQUAL 
%token ASSIGNMENT_DIV_EQUAL 
%token ASSIGNMENT_REM_EQUAL 
%token ASSIGNMENT_LSHIFT_EQUAL 
%token ASSIGNMENT_RSHIFT_EQUAL 
%token ASSIGNMENT_AND_EQUAL 
%token ASSIGNMENT_XOR_EQUAL 
%token ASSIGNMENT_OR_EQUAL 
%token LSHIFT, RSHIFT

/* TYPE -> declares the expressions that will have numeric values */
/* I will need to define a shit ton of these since we can't use the built in precedence thing */ 
/* need one for each, asssignment, bitwise or, bitwise xor, etc. */
%type <num> assignment_expr 
%type <num> bitwise_or_expr 
%type <num> bitwise_xor_expr 
%type <num> bitwise_and_expr 
%type <num> shift_expr
%type <num> add_sub_expr
%type <num> mult_div_rem_expr
%type <num> negation_expr
%type <num> bitwise_not_expr
%type <num> factor

%%
commands:
	|	commands command
	;


command	:	assignment_expr ';'           { printf("%d\n", $1); }
        | CLEAR ';'                     { clear(); } 
        | DUMP  ';'                     { dump(); }
	      ;

assignment_expr : ID '=' assignment_expr                      { $$ = vars[$1] = $3; } 
                | ID ASSIGNMENT_ADD_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] + $3; }
                | ID ASSIGNMENT_SUB_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] - $3; }
                | ID ASSIGNMENT_MULT_EQUAL assignment_expr    { $$ = vars[$1] = vars[$1] * $3; }
                | ID ASSIGNMENT_DIV_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] / $3; }
                | ID ASSIGNMENT_REM_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] % $3; }
                | ID ASSIGNMENT_LSHIFT_EQUAL assignment_expr  { $$ = vars[$1] = vars[$1] << $3; }
                | ID ASSIGNMENT_RSHIFT_EQUAL assignment_expr  { $$ = vars[$1] = vars[$1] >> $3; }
                | ID ASSIGNMENT_AND_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] & $3; }
                | ID ASSIGNMENT_XOR_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] ^ $3; }
                | ID ASSIGNMENT_OR_EQUAL assignment_expr      { $$ = vars[$1] = vars[$1] | $3; }
                | bitwise_or_expr                             { $$ = $1; }
                ;

bitwise_or_expr : bitwise_or_expr '|' add_sub_expr     { $$ = $1 | $3; }
                | add_sub_expr                         { $$ = $1; }
                ;

add_sub_expr : add_sub_expr '+' factor   { $$ = $1 + $3; }
             | add_sub_expr '-' factor   { $$ = $1 - $3; }
	           | factor                    { $$ = $1; }
	           ;

factor : '(' add_sub_expr ')' { $$ = $2; }
       | NUM                  { $$ = $1; }
       | ID                   { $$ = vars[$1]; }
       ;
%%

/* function to handle 'clear'. Loops and sets all values to zero. */
void clear() {
    for (int i = 0; i < VARS; i++) {
      vars[i] = 0;
   }
}
/* function to handle 'dump'. Just loops through the VARS, prints each letter
and its corresponding value */
void dump() {
  for (int i = 0; i < VARS; i++) {
    printf("%c: %d\n", 'a'+i, vars[i]);

  }
}

main()
{
   /* Initialize all variables (a-z) to 0 */
   for (int i = 0; i < VARS; i++) {
      vars[i] = 0;
   }
   
   /* IF any errors are enocuntered or eof */
   if (yyparse())
      printf("\nInvalid expression.\n");
   else
      printf("\nCalculator off.\n");
}

/* Error stuff */
yyerror(s)
char *s;
{
   fprintf(stderr, "%s\n", s);
}
