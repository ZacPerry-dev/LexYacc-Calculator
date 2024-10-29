/*
 * COSC: 561 - Compilers & Runtime Systems - Assignment 2: Cexpr
 * Zachary Perry
 * 10/29/24
 */

%{
#include <stdio.h>
#include <limits.h>

// something to hold variables
#define VARS 26
#define maxIntegerValue 2147483647
#define minIntegerValue -2147483648

// Holds the different variables and their values
int vars[VARS];

// function definitions
void yyerror(char *);
int yylex();
void clear();
void dump();
int errorCheckOverflow(long long, long long, char *);
%}

/* UNION -> defines the possible types for tokens / values */
%union {
  long long num;
  int var;
  int test;
}

/* TOKEN -> declares a token type of numbers */
%token <num> NUM
%token <test> ID
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
        | error ';'                     { yyerrok; }
        | CLEAR ';'                     { clear(); } 
        | DUMP  ';'                     { dump(); }
	      ;

assignment_expr : ID '=' assignment_expr                      { if (errorCheckOverflow(vars[$1], $3, "=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = $3;
                                                              }
                | ID ASSIGNMENT_ADD_EQUAL assignment_expr     { if (errorCheckOverflow(vars[$1], $3, "+=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] + $3;
                                                              }
                | ID ASSIGNMENT_SUB_EQUAL assignment_expr     { if (errorCheckOverflow(vars[$1], $3, "-=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] - $3;
                                                              }
                | ID ASSIGNMENT_MULT_EQUAL assignment_expr    { if (errorCheckOverflow(vars[$1], $3, "*=")) { 
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] * $3;
                                                              }
                | ID ASSIGNMENT_DIV_EQUAL assignment_expr     { if ($3 == 0) {
                                                                  yyerror("dividebyzero");
                                                                  YYERROR;
                                                                }
                                                                else if (errorCheckOverflow(vars[$1], $3, "/=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] / $3; 
                                                              }    
                | ID ASSIGNMENT_REM_EQUAL assignment_expr     { if ($3 == 0) {
                                                                  yyerror("dividebyzero");
                                                                  YYERROR;
                                                                }
                                                                else if (errorCheckOverflow(vars[$1], $3, "%=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] % $3; 
                                                              }
                | ID ASSIGNMENT_LSHIFT_EQUAL assignment_expr  { if (errorCheckOverflow(vars[$1], $3, "<<=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] << $3; 
                                                              }
                | ID ASSIGNMENT_RSHIFT_EQUAL assignment_expr  { if (errorCheckOverflow(vars[$1], $3, ">>=")) {
                                                                yyerror("overflow");
                                                                YYERROR;
                                                                } else $$ = vars[$1] = vars[$1] >> $3;
                                                              }
                | ID ASSIGNMENT_AND_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] & $3; }
                | ID ASSIGNMENT_XOR_EQUAL assignment_expr     { $$ = vars[$1] = vars[$1] ^ $3; }
                | ID ASSIGNMENT_OR_EQUAL assignment_expr      { $$ = vars[$1] = vars[$1] | $3; }
                | bitwise_or_expr                             { $$ = $1; }
                ;

bitwise_or_expr : bitwise_or_expr '|' bitwise_xor_expr  { $$ = $1 | $3; }
                | bitwise_xor_expr                      { $$ = $1; }
                ;

bitwise_xor_expr : bitwise_xor_expr '^' bitwise_and_expr  { $$ = $1 ^ $3; }
                 | bitwise_and_expr                       { $$ = $1; }
                 ;

bitwise_and_expr : bitwise_and_expr '&' shift_expr { $$ = $1 & $3; }
                 | shift_expr                      { $$ = $1; }
                 ;

shift_expr : shift_expr LSHIFT add_sub_expr { if (errorCheckOverflow($1, $3, "<<")){
                                                yyerror("overflow");
                                                YYERROR;
                                              } $$ = $1 << $3;
                                            } 
           | shift_expr RSHIFT add_sub_expr { if (errorCheckOverflow($1, $3, ">>")){
                                                yyerror("overflow");
                                                YYERROR;
                                              } else $$ = $1 >> $3;
                                            }
           | add_sub_expr
           ;

add_sub_expr : add_sub_expr '+' mult_div_rem_expr { if (errorCheckOverflow($1, $3, "+")) {
                                                      yyerror("overflow");
                                                      YYERROR;
                                                    } else $$ = $1 + $3;
                                                  }
             | add_sub_expr '-' mult_div_rem_expr { if (errorCheckOverflow($1, $3, "-")) {
                                                      yyerror("overflow");
                                                      YYERROR;
                                                    } else $$ = $1 - $3;
                                                  }
	           | mult_div_rem_expr                  { $$ = $1; }
	           ;

mult_div_rem_expr : mult_div_rem_expr '*' negation_expr { if (errorCheckOverflow($1, $3, "*")) {
                                                            yyerror("overflow");
                                                            YYERROR;
                                                          } else $$ = $1 * $3;
                                                        }
                  | mult_div_rem_expr '/' negation_expr { if ($3 == 0) {
                                                              yyerror("dividebyzero");
                                                              YYERROR;
                                                          }
                                                          else if (errorCheckOverflow($1, $3, "/")){
                                                            yyerror("overflow");
                                                            YYERROR;
                                                          } else $$ = $1 / $3; 
                                                        }
                  | mult_div_rem_expr '%' negation_expr { if ($3 == 0) {
                                                            yyerror("dividebyzero");
                                                            YYERROR;
                                                          } 
                                                          else if (errorCheckOverflow($1, $3, "%")){
                                                            yyerror("overflow");
                                                            YYERROR; 
                                                          } else $$ = $1 % $3; 
                                                        }
                  | negation_expr                       { $$ = $1; }
                  ;

negation_expr : '-' negation_expr { if (errorCheckOverflow($2, 0, "negate")) {
                                      yyerror("overflow");
                                      YYERROR;
                                    } else $$ = -$2; 
                                  }
              | bitwise_not_expr  { $$ = $1; }
              ;

bitwise_not_expr : '~' bitwise_not_expr { $$ = ~$2; }
                 |  factor              { $$ = $1; }
                 ;

factor : '(' assignment_expr ')'  { $$ = $2; }
       | NUM                      { if (errorCheckOverflow($1, 0, "")) {
                                      yyerror("overflow");
                                      YYERROR;
                                    } else $$ = $1; 
                                  }
       | ID                       { $$ = vars[$1]; }
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

int errorCheckOverflow(long long x, long long y, char *operator) {
  
  // Just general bounds checking
  if (y > INT_MAX || y < INT_MIN || x > INT_MAX || x < INT_MIN) return 1;
  
  // Left shift -> if shifted by any negatives, it will overflow.
  else if ((operator == "<<" || operator == "<<=")) {
    if (y < 0 || y > sizeof(int) * 8) return 1;
  }
  // Right shift -> shifting by negative doesn't matter here.
  else if ((operator == ">>" || operator == ">>="  )) {
    // Pretty sure this could cause unexpected behavior but not overflow? Returning 0 here instead?
    if (y < 0) return 0;
    else if (y > sizeof(int) * 8) return 1;
  }

  // Overflow + underflow check for +, +=
  else if ((operator == "+" || operator == "+=")) {
   if (y > 0 && (x > INT_MAX - y)) return 1; 
   else if (y < 0 && (x < INT_MIN - y)) return 1;
  }

  // Sub check -- overflow & underflow
  else if ((operator == "-" || operator == "-=")) {
   if (y < 0 && (x > INT_MAX + y)) return 1;
   else if (y > 0 && (x < INT_MIN + y)) return 1;
  }
  
  // Mult check (check to make sure I don't accidentally try and divide by zero here
  else if ((operator == "*" || operator == "*=")) {
    if (y != 0 && x > INT_MAX / y) return 1;
    else if (y != 0 && x < INT_MIN / y) return 1;
  }

  // small division check & modulo
  else if ((operator == "/" || operator == "/=" || operator == "%" || operator == "%=")) {
    if (x == INT_MIN && y == -1) return 1;
  }

  // Negation check -- just passing a string so it doesn't interfere with - and -=
  else if (operator == "negate") {
    if (x == INT_MIN) return 1;
  }

  return 0;
}

/* function to print out error messages */
void yyerror(char *s) {
   printf("%s\n", s);
}

int main() {
   /* Initialize all variables (a-z) to 0 */
   for (int i = 0; i < VARS; i++) {
      vars[i] = 0;
   }
   
   /* IF any errors are enocuntered or eof */
   if (yyparse())
      printf("\nInvalid expression.\n");
   else
      printf("\nCalculator off.\n");

  return 0;
}
