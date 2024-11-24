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
%token DIV
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
%token ATT
%token METH
%token CLASS
%token NEW
%token THIS
%token VOID
%token VIRG
%token DOT
%token POW

%left PLUS MINUS
%left STAR DIV
%left POW

%start program
%type <Kawa.program> program

%%

program:
| MAIN BEGIN main=list(instruction) END EOF
    { {classes=[]; globals=[]; main} }
;

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }



typ: 
| INT{TInt}
| BOOL{TBool}
| VOID{TVoid}
| id=IDENT{TClass(id)}


;

expression:
| n=INT { Int(n) }
| op=uop e=expression{Unop(op, e )}
| e1 = expression op = bop e2 = expression{Binop(op, e1, e2)}
| MINUS n=INT {Int(-n)}
| LPAR e = expression RPAR {e}

;


uop:
| MINUS{Opp}
| NOT{Not}
;
%inline bop:
| PLUS{Add}  |   MOD{Mod}  | INFEQ{Infeq} | OR{Or}
| MINUS{Sub} |   DEQ{Eq}   | SUP{Sup}     | POW{Pow}
| STAR{Mul}  |   DIFF{Neq} | SUPEQ{Supeq}
| DIV{Div}   |   INF{Inf}  | AND{And}
;