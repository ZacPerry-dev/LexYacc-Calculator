# LexYacc-Calculator
Calculator of C integer expressions written in Lex &amp; Yacc

TODO: 
- [x] Extend the Makefile? 
- [x] Start with unary operations
- [x] Figure out what the actual C file is doing, including the header file
- [x] Add support for variable definitions (a-z, lowercase)
- [x] Define rest of the operations and tokens within lex
- [x] Get tokens and stuff made in Yacc
- [x] Implement all operations (most done) 
- [ ] Add specific error checking (this will be annoying to add)
- [ ] Comment code 
- [ ] Report
- [ ] More testing (Cases like: 9a, 10000, capitals, etc).

** files I will be adding to are defined in src. look ever examples first ** 

Goals: 
- Process expressions until it encounters EOF or invalid syntax
- each calculation is terminated by a semicolon 
- Tokens can be seperated by whitespace, but NO COMMONTS? 
- Tokens include integer numbers (0-9, all combos) and 26 pre-defined integer variables
- one variable corresponding to each of the lowercase letters in the alphabet (a-z) 
- Implement specific c operators
    - No operator may precede an assignment operator in a calculation except another assignment operator. 

- Need to define extra nonterminals and productions to enforce the specified associativity and precendence for this assignment 
- Detect error conditions, which include integer overflow and divide by zero 
- When an error is detected, print an appropriate message indicating the error
    - Do not perform any assignments in a calculation after encountering an error 

## NOTES for writeup:
- Integer overflow checking
  - Since there can be wrap around when adding two numbers together (resulting in unexpected negative beahvior) i had to check each inidividual thing
- Error checking in general
  - error, yyerrok, YYERROR, behavior and why I used it   
  - For error checking overflow and underflow 
- Approaches to the tokens, etc 
- Structure of everything, expr, etc. 
- Different functions
- How i stored variabels and their values


# NOTE: 
Error checking the overflow and underflow is odd. Basically, in order to handle cases where the value is too large for an int, we must cast it to a long long? first, then pass it to the function. If its greater than the max or less than the min, then it's an overflow. Otherwise, convert to an int and then check the operations???

code works as long as none of the individual values exceeds 2,147,483,647.

ex: 
```
a = 1; 
a += 80000000000000;
```
