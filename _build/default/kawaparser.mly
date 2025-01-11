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
%token UMINUS
      
%token EXT 




%right EQ             // Affectation
%left OR              // OU logique
%left AND             // ET logique
%left DEQ DIFF        // Égalité et différence
%left INF INFEQ SUP SUPEQ // Comparaison
%left PLUS MINUS      // Addition et soustraction (binaire)
%left STAR DIV MOD    // Multiplication, division, modulo
%right POW            // Puissance (associativité à droite)
%right NOT
// Opérateurs unaires NOT e
%nonassoc DOT


%start program
%type <Kawa.program> program
%%
program:
  | variables=list(var_decl) cls=list(class_def) MAIN BEGIN main=list(instruction) END EOF
    { { classes = cls; globals = variables; main = main } }
;

attr_decl:
  | ATT t=typ id=IDENT SEMI { (id, t) }
;

class_def:
  | CLASS id=IDENT BEGIN attributes=list(attr_decl) methods=list(method_def) END
    { { class_name = id; attributes = attributes; methods = methods; parent = None } }
    
  | CLASS id=IDENT EXT pa = IDENT BEGIN attributes=list(attr_decl) methods=list(method_def) END
    { { class_name = id; attributes = attributes; methods = methods; parent = Some pa } }

;

method_def:
  | METH t=typ name=IDENT LPAR params=list(param) RPAR BEGIN locals=list(var_decl) instrs=list(instruction) END
    { { method_name = name; code = instrs; params = params; locals = locals; return = t } }
;

instruction:
  | PRINT LPAR e=expression RPAR SEMI { Print(e) }
  | m=mem EQ e=expression SEMI { Set(m, e) }
  | IF LPAR cond=expression RPAR BEGIN instructions1=list(instruction) END ELSE BEGIN instructions2=list(instruction) END
    { If(cond, instructions1, instructions2) }
  | WHILE LPAR cond=expression RPAR BEGIN block=list(instruction) END
    { While(cond, block) }
  | RETURN e=expression SEMI { Return(e) }
  | e = expression SEMI{Expr(e)}
;


param_del:
  | e = expression {[e]}
  | e = expression VIRG l = param_del {e::l}
  | {[]}
;




param:
  | t=typ id=IDENT VIRG { (id, t) }
  | t=typ id=IDENT { (id, t) }
;

mem:
  | id=IDENT { Var(id) }
  | e=expression DOT id=IDENT { Field(e, id) }
;

typ:
  | VARINT { TInt }
  | VARBOOL { TBool }
  | VOID { TVoid }
  | id=IDENT { TClass(id) }
;

var_decl:
  | VAR t=typ id=IDENT SEMI { (id, t) }
;
expression:
  | n=INT { Int(n) }
  | TRUE { Bool(true) }
  | FALSE { Bool(false) }
  | op=uop e=expression { Unop(op, e) }
  | e1=expression op=bop e2=expression { Binop(op, e1, e2) }
  | MINUS n=INT { Int(-n) }
  | LPAR e=expression RPAR { e }
  | id=IDENT { Get(Var(id)) }
  | THIS { This }
  | m=mem { Get(m) }
  | NEW id=IDENT { New(id) }
  | NEW id=IDENT LPAR exprs=param_del RPAR { NewCstr(id, exprs) }
  | e=expression DOT id=IDENT LPAR params=param_del RPAR { MethCall(e, id, params) }
;


uop:
  | MINUS{ Opp }
  | NOT { Not }
;


%inline bop:
  | PLUS { Add }
  | MOD { Mod }
  | INFEQ { Infeq }
  | OR { Or }
  | MINUS { Sub }
  | DEQ { Eq }
  | SUP { Sup }
  | POW { Pow }
  | STAR { Mul }
  | DIFF { Neq }
  | SUPEQ { Supeq }
  | DIV { Div }
  | INF { Inf }
  | AND { And }
;
