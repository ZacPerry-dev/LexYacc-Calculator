/* COSC: 561 - Compilers & Runtime Systems - Assignment 2: Cexpr
 * Zachary Perry
 * 10/29/24
 */

%{
#include <stdio.h>
#include <limits.h>

// Defining 26 vals to represent letters a-z.
#define VALS 26

// vals holds the various values of each letter variable. Can be accessed, cleared, set, etc.
// Syntax error here is used to signal a syntax error found in the code. When this happens, code execution will stop and the program will end.
int vals[VALS];
int syntaxError = 0;

// Function definitions: 
// 1. yylex was defined here to return an int, getting rid of warnings after being compiled.
// 2. clear() will clear all values from the vals array, each letter having a value of 0.
// 3. dump() will print out all letter variables and their associated values.
// 4. yyerror() will print out error messages.
// 5. errorCheckOverflow() will take in the current operands, operation, and determine if an overflow will happen or if one is present.
int yylex();
void clear();
void dump();
void yyerror(char *);
int errorCheckOverflow(long long, long long, char *);
%}

/* UNION -> defines the possible types for tokens & values */
// num represents the operands, val & id are used for the letter variables + their associated values.
%union {
  long long num;
  int val;
  int id;
}

/* TOKEN -> defines tokens of different types to represent different operations, values, etc. These come from Lex */
%token <num> NUM
%token <id> ID
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

/* TYPE -> defines non-terminals and their different value types. In this case, these all are of type num (long long) */
%type <num> assignment_expr 
%type <num> bitwise_or_expr 
%type <num> bitwise_xor_expr 
%type <num> bitwise_and_expr
%type <num> shift_expr
%type <num> add_sub_expr
%type <num> mult_div_rem_expr
%type <num> negation_expr
%type <num> bitwise_not_expr
%type <num> fin

/* All commands below will handle the different expected integer C operations, as well as error check. */
%%
commands:
	|	commands command
	;

command	:	assignment_expr ';'   { printf("%d\n", $1); }
        | error ';'             { if (syntaxError == 1) YYABORT;
                                  else yyerrok; 
                                }
        | CLEAR ';'             { clear(); } 
        | DUMP  ';'             { dump(); }
	      ;

assignment_expr : ID '=' assignment_expr                      { if (errorCheckOverflow(vals[$1], $3, "=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = $3;
                                                              }
                | ID ASSIGNMENT_ADD_EQUAL assignment_expr     { if (errorCheckOverflow(vals[$1], $3, "+=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] + $3;
                                                              }
                | ID ASSIGNMENT_SUB_EQUAL assignment_expr     { if (errorCheckOverflow(vals[$1], $3, "-=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] - $3;
                                                              }
                | ID ASSIGNMENT_MULT_EQUAL assignment_expr    { if (errorCheckOverflow(vals[$1], $3, "*=")) { 
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] * $3;
                                                              }
                | ID ASSIGNMENT_DIV_EQUAL assignment_expr     { if ($3 == 0) {
                                                                  yyerror("dividebyzero");
                                                                  YYERROR;
                                                                }
                                                                else if (errorCheckOverflow(vals[$1], $3, "/=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] / $3; 
                                                              }    
                | ID ASSIGNMENT_REM_EQUAL assignment_expr     { if ($3 == 0) {
                                                                  yyerror("dividebyzero");
                                                                  YYERROR;
                                                                }
                                                                else if (errorCheckOverflow(vals[$1], $3, "%=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] % $3; 
                                                              }
                | ID ASSIGNMENT_LSHIFT_EQUAL assignment_expr  { if (errorCheckOverflow(vals[$1], $3, "<<=")) {
                                                                  yyerror("overflow");
                                                                  YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] << $3; 
                                                              }
                | ID ASSIGNMENT_RSHIFT_EQUAL assignment_expr  { if (errorCheckOverflow(vals[$1], $3, ">>=")) {
                                                                yyerror("overflow");
                                                                YYERROR;
                                                                } else $$ = vals[$1] = vals[$1] >> $3;
                                                              }
                | ID ASSIGNMENT_AND_EQUAL assignment_expr     { $$ = vals[$1] = vals[$1] & $3; }
                | ID ASSIGNMENT_XOR_EQUAL assignment_expr     { $$ = vals[$1] = vals[$1] ^ $3; }
                | ID ASSIGNMENT_OR_EQUAL assignment_expr      { $$ = vals[$1] = vals[$1] | $3; }
                | bitwise_or_expr                             { $$ = $1; }
                ;

bitwise_or_expr : bitwise_or_expr '|' bitwise_xor_expr    { $$ = $1 | $3; }
                | bitwise_xor_expr                        { $$ = $1; }
                ;

bitwise_xor_expr : bitwise_xor_expr '^' bitwise_and_expr  { $$ = $1 ^ $3; }
                 | bitwise_and_expr                       { $$ = $1; }
                 ;

bitwise_and_expr : bitwise_and_expr '&' shift_expr        { $$ = $1 & $3; }
                 | shift_expr                             { $$ = $1; }
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
                 |  fin                 { $$ = $1; }
                 ;

fin : '(' assignment_expr ')'   { $$ = $2; }
       | NUM                    { if (errorCheckOverflow($1, 0, "")) {
                                    yyerror("overflow");
                                    YYERROR;
                                  } else $$ = $1; 
                                }
       | ID                     { $$ = vals[$1]; }
       ;
%%

/* CLEAR: function to handle 'clear'. Loops and sets all values to zero. */
void clear() {
    for (int i = 0; i < VALS; i++) {
      vals[i] = 0;
   }
}
/* DUMP: function to handle 'dump'. Just loops through the VALS, prints each letter and its corresponding value. */
void dump() {
  for (int i = 0; i < VALS; i++) {
    printf("%c: %d\n", 'a'+i, vals[i]);
  }
}

/* errorCheckOverflow: checks for current and potential overflow errors for many of the operations. If 1 is returned, overflow occured. */
int errorCheckOverflow(long long x, long long y, char *operator) {
  
  // Just general bounds checking
  if (y > INT_MAX || y < INT_MIN || x > INT_MAX || x < INT_MIN) return 1;
  
  // Left shift 
  else if ((operator == "<<" || operator == "<<=")) {
    if (y < 0 || y > sizeof(int) * 8) return 1;
  }
  // Right shift 
  else if ((operator == ">>" || operator == ">>="  )) {
    if (y < 0) return 0;
    else if (y > sizeof(int) * 8) return 1;
  }

  // +, +=
  else if ((operator == "+" || operator == "+=")) {
   if (y > 0 && (x > INT_MAX - y)) return 1; 
   else if (y < 0 && (x < INT_MIN - y)) return 1;
  }

  // -, -=
  else if ((operator == "-" || operator == "-=")) {
   if (y < 0 && (x > INT_MAX + y)) return 1;
   else if (y > 0 && (x < INT_MIN + y)) return 1;
  }
  
  // *, *=
  else if ((operator == "*" || operator == "*=")) {
    if (y != 0 && x > INT_MAX / y) return 1;
    else if (y != 0 && x < INT_MIN / y) return 1;
  }

  // /, /=, %, %=
  else if ((operator == "/" || operator == "/=" || operator == "%" || operator == "%=")) {
    if (x == INT_MIN && y == -1) return 1;
  }

  // negation 
  else if (operator == "negate") {
    if (x == INT_MIN) return 1;
  }

  return 0;
}

/* yyerror: function to print out error messages */
void yyerror(char *s) {
  if (s == "syntax error") syntaxError = 1;
  printf("%s\n", s);
}

int main() {
  // Initialize all vals for each letter to 0.
  for (int i = 0; i < VALS; i++) {
    vals[i] = 0;
  }
   
  if (yyparse())
     printf("\nInvalid expression.\n");
  else
     printf("\nCalculator off.\n");

  return 0;
}
