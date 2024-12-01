%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <string> IDENT
%token <bool> BOOL
%token TRUE
%token FALSE
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
%token VARINT
%token VARBOOL

%left SUP SUPEQ INF INFEQ DEQ DIFF

%left AND OR 

%left PLUS MINUS
%left MOD
%left STAR DIV
%left POW





%start program
%type <Kawa.program> program

%%

program:
|variables=list(var_decl) MAIN BEGIN main=list(instruction) END EOF
    { {classes=[]; globals = variables; main} }
;

instruction:
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| m=mem EQ e=expression SEMI{Set(m , e)}
| IF LPAR cond = expression RPAR BEGIN instructions1 = list(instruction) END
 ELSE BEGIN instructions2 = list(instruction) END{If(cond, instructions1, instructions2)}
| WHILE LPAR cond = expression RPAR BEGIN block = list(instruction) END{While(cond, block)}


;

mem:
| id =IDENT{Var(id)}

;


typ: 
| VARINT{TInt}
| VARBOOL{TBool}
| VOID{TVoid}
| id=IDENT{TClass(id)}
;

var_decl: 
| VAR t=typ id=IDENT SEMI{(id,t) } ;

expression:
| n=INT { Int(n) }
| TRUE{Bool(true)}
| FALSE{Bool(false)}
| op=uop e=expression{Unop(op, e )}
| e1 = expression op = bop e2 = expression{Binop(op, e1, e2)}
| MINUS n=INT {Int(-n)}
| LPAR e = expression RPAR {e}
| id = IDENT{Get(Var(id))}

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