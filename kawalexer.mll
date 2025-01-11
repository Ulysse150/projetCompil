{

  open Lexing
  open Kawaparser

  exception Error of string

  let keyword_or_ident =
  let h = Hashtbl.create 17 in
  List.iter (fun (s, k) -> Hashtbl.add h s k)
    [ "print",    PRINT;
      "main",     MAIN;
      "if",       IF;
      "else",     ELSE;
      "var",      VAR;
      "return",   RETURN;
      "attribute", ATT;
      "method",    METH;
      "class",      CLASS;
      "new",       NEW;
      "this",     THIS;
      "void",     VOID;
      "true", TRUE;
      "false", FALSE;
      "int", VARINT;
      "bool", VARBOOL;
      "while", WHILE;
      "extends", EXT
    ] ;
  fun s ->
    try  Hashtbl.find h s
    with Not_found -> IDENT(s)
        
}

let digit = ['0'-'9']
let number = digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*


rule token = parse
  | ['\n']            { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+  { token lexbuf }

  | "//" [^ '\n']* "\n"  { new_line lexbuf; token lexbuf }
  | "/*"                 { comment lexbuf; token lexbuf }

  | number as n  { INT(int_of_string n) }
  | ident as id  { keyword_or_ident id }


  | ";"  { SEMI }
  | "("  { LPAR }
  | ")"  { RPAR }
  | "{"  { BEGIN }
  | "}"  { END }
  
  |"*"{STAR}
  |"/"{DIV}
  |"="{EQ}
  |"+"{PLUS}
  |"-"{MINUS}
  |"=="{DEQ}
  |"!="{DIFF}
  |"<"{INF}
  |"<="{INFEQ}
  |"&&"{AND}
  |"||"{OR}
  |">"{SUP}
  |">="{SUPEQ}
  |"!"{NOT}
  |"%" {MOD}
  |"," {VIRG}
  |"." {DOT}
  |"^"{POW}
  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }
