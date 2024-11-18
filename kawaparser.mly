%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <string> IDENT
%token <bool> BOOL
%token MAIN
%token LPAR RPAR BEGIN END SEMI
%token PRINT
%token EOF
%token IF ELSE
%token WHILE 
%token RETURN
%token VAR
%token EQ
%token PLUS
%token MINUS
%token STAR
%token DIVIDE
%token DEQ
%token DIFF
%token INF
%token INFEQ
%token AND
%token OR
%token SUP
%token SUPEQ
%token NOT
%token MOD
%start program
%type <Kawa.program> program

%%

program:
| MAIN BEGIN main=list(instruction) END EOF
    { {classes=[]; globals=[]; main} }
;

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| IF LPAR e1=expression RPAR ELSE e2=expression

;

expression:
| n=INT { Int(n) }

;


