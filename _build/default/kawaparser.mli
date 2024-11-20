
(* The type of tokens. *)

type token = 
  | WHILE
  | VOID
  | VIRG
  | VAR
  | THIS
  | SUPEQ
  | SUP
  | STAR
  | SEMI
  | RPAR
  | RETURN
  | PRINT
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
