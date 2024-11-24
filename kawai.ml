open Format
open Lexing

let file = Sys.argv.(1)

let report (b,e) =
  let l = b.pos_lnum in
  let fc = b.pos_cnum - b.pos_bol + 1 in
  let lc = e.pos_cnum - b.pos_bol + 1 in
  eprintf "File \"%s\", line %d, characters %d-%d:\n" file l fc lc

let () =
  let c  = open_in file in
  let lb = Lexing.from_channel c in
  try
      Printf.printf"Lexing et parsing du fichier...\n";
    let prog = Kawaparser.program Kawalexer.token lb in
    Printf.printf"Lexing et parsing du fichier effectués avec succès\n" ;
    close_in c;
    Printf.printf"Typechecking du programme...\n";
    Typechecker.typecheck_prog prog;
    Printf.printf"Typechecking du programme effectue avec succes\n";
    Printf.printf"Execution du programme...\n";
    Interpreter.exec_prog prog;
    Printf.printf"Programme execute avec succes...\n";
    exit 0
  with
  | Kawalexer.Error s ->
     report (lexeme_start_p lb, lexeme_end_p lb);
     eprintf "lexical error: %s@." s;
     exit 1
  | Kawaparser.Error ->
     report (lexeme_start_p lb, lexeme_end_p lb);
     eprintf "syntax error@.";
     exit 1
  | Interpreter.Error s ->
     eprintf "interpreter error: %s@." s;
     exit 1
  | e ->
     eprintf "Anomaly: %s\n@." (Printexc.to_string e);
     exit 2
