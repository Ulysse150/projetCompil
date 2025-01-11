
(* The type of tokens. *)

type token = 
  | WHILE
  | VOID
  | VIRG
  | VARINT
  | VARBOOL
  | VAR
  | UMINUS
  | TRUE
  | THIS
  | SUPEQ
  | SUP
  | STAR
  | SEMI
  | RPAR
  | RETURN
  | PRINT
  | POW
  | PLUS
  | OR
  | NOT
  | NEW
  | MOD
  | MINUS
  | METH
  | MAIN
  | LPAR
  | INT of (int)
  | INFEQ
  | INF
  | IF
  | IDENT of (string)
  | FALSE
  | EXT
  | EQ
  | EOF
  | END
  | ELSE
  | DOT
  | DIV
  | DIFF
  | DEQ
  | CLASS
  | BOOL of (bool)
  | BEGIN
  | ATT
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
