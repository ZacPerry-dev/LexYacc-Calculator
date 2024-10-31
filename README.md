# LexYacc-Calculator
Calculator of C integer expressions written in Lex &amp; Yacc


Goals: 
- Process expressions until it encounters EOF or invalid syntax
- each calculation is terminated by a semicolon 
- Tokens can be seperated by whitespace 
- Tokens include integer numbers (0-9, all combos) and 26 pre-defined integer variables
- one variable corresponding to each of the lowercase letters in the alphabet (a-z) 
- Implement specific c operators
    - No operator may precede an assignment operator in a calculation except another assignment operator. 

- Need to define extra nonterminals and productions to enforce the specified associativity and precendence for this assignment 
- Detect error conditions, which include integer overflow and divide by zero 
- When an error is detected, print an appropriate message indicating the error
    - Do not perform any assignments in a calculation after encountering an error 

### Tests: 
- Addition:           +, +=, a = _ + _ overflow
- Subtraction:        -, -=, a = _ - _ overflow
- Multiplication:     *, *=, a = _ * _ overflow
- Division:           /, /=, a = _ / _ overflow, divbyzero
- Modulo:             %, %=, a = _ % _ overflow, divbyzero
- Shifting (left):    <<, <<=, a = _ << _ overflow
- Shifting (right):   >>, >>=, a = _ >> _ overflow 
- And:                &, &=, a = _ & _ 
- Or:                 |, |=, a = _ | _
- Xor:                ^, ^=, a = _ ^ _
- Not:                ~
- Negate:             -, overflow

- Random (with parenthesis): 
- Random assignment overflows
