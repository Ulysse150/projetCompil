
(* The type of tokens. *)

type token = 
  | SEMI
  | RPAR
  | PRINT
  | MAIN
  | LPAR
  | INT of (int)
  | IDENT of (string)
  | EOF
  | END
  | BEGIN

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
