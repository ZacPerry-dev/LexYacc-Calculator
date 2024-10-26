# LexYacc-Calculator
Calculator of C integer expressions written in Lex &amp; Yacc

TODO: 
- [x] Extend the Makefile? 
- [x] Start with unary operations
- [x] Figure out what the actual C file is doing, including the header file
- [x] Add support for variable definitions (a-z, lowercase)
- [x] Define rest of the operations and tokens within lex
- [x] Get tokens and stuff made in Yacc
- [ ] Implement all operations (most done) 
- [ ] Add specific error checking
- [ ] Comment code 
- [ ] Report

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


