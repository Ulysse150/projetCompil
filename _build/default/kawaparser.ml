
module MenhirBasics = struct
  
  exception Error
  
  let _eRR =
    fun _s ->
      raise Error
  
  type token = 
    | SEMI
    | RPAR
    | PRINT
    | MAIN
    | LPAR
    | INT of (
# 8 "kawaparser.mly"
       (int)
# 20 "kawaparser.ml"
  )
    | IDENT of (
# 9 "kawaparser.mly"
       (string)
# 25 "kawaparser.ml"
  )
    | EOF
    | END
    | BEGIN
  
end

include MenhirBasics

# 1 "kawaparser.mly"
  

  open Lexing
  open Kawa


# 42 "kawaparser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState02 : ('s, _menhir_box_program) _menhir_state
    (** State 02.
        Stack shape : .
        Start symbol: program. *)

  | MenhirState12 : (('s, _menhir_box_program) _menhir_cell1_instruction, _menhir_box_program) _menhir_state
    (** State 12.
        Stack shape : instruction.
        Start symbol: program. *)


and ('s, 'r) _menhir_cell1_instruction = 
  | MenhirCell1_instruction of 's * ('s, 'r) _menhir_state * (Kawa.instr)

and ('s, 'r) _menhir_cell1_PRINT = 
  | MenhirCell1_PRINT of 's * ('s, 'r) _menhir_state

and _menhir_box_program = 
  | MenhirBox_program of (Kawa.program) [@@unboxed]

let _menhir_action_1 =
  fun n ->
    (
# 30 "kawaparser.mly"
        ( Int(n) )
# 70 "kawaparser.ml"
     : (Kawa.expr))

let _menhir_action_2 =
  fun e ->
    (
# 26 "kawaparser.mly"
                                    ( Print(e) )
# 78 "kawaparser.ml"
     : (Kawa.instr))

let _menhir_action_3 =
  fun () ->
    (
# 216 "<standard.mly>"
    ( [] )
# 86 "kawaparser.ml"
     : (Kawa.seq))

let _menhir_action_4 =
  fun x xs ->
    (
# 219 "<standard.mly>"
    ( x :: xs )
# 94 "kawaparser.ml"
     : (Kawa.seq))

let _menhir_action_5 =
  fun main ->
    (
# 22 "kawaparser.mly"
    ( {classes=[]; globals=[]; main} )
# 102 "kawaparser.ml"
     : (Kawa.program))

let _menhir_print_token : token -> string =
  fun _tok ->
    match _tok with
    | BEGIN ->
        "BEGIN"
    | END ->
        "END"
    | EOF ->
        "EOF"
    | IDENT _ ->
        "IDENT"
    | INT _ ->
        "INT"
    | LPAR ->
        "LPAR"
    | MAIN ->
        "MAIN"
    | PRINT ->
        "PRINT"
    | RPAR ->
        "RPAR"
    | SEMI ->
        "SEMI"

let _menhir_fail : unit -> 'a =
  fun () ->
    Printf.eprintf "Internal failure -- please contact the parser generator's developers.\n%!";
    assert false

include struct
  
  [@@@ocaml.warning "-4-37"]
  
  let _menhir_run_09 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> _menhir_box_program =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let main = _v in
          let _v = _menhir_action_5 main in
          MenhirBox_program _v
      | _ ->
          _eRR ()
  
  let rec _menhir_run_13 : type  ttv_stack. (ttv_stack, _menhir_box_program) _menhir_cell1_instruction -> _ -> _ -> _ -> _menhir_box_program =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_instruction (_menhir_stack, _menhir_s, x) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_4 x xs in
      _menhir_goto_list_instruction_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_list_instruction_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_program) _menhir_state -> _menhir_box_program =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState12 ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | MenhirState02 ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v
  
  let rec _menhir_run_03 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_program) _menhir_state -> _menhir_box_program =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_PRINT (_menhir_stack, _menhir_s) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | LPAR ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | INT _v ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              let n = _v in
              let _v = _menhir_action_1 n in
              (match (_tok : MenhirBasics.token) with
              | RPAR ->
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  (match (_tok : MenhirBasics.token) with
                  | SEMI ->
                      let _tok = _menhir_lexer _menhir_lexbuf in
                      let MenhirCell1_PRINT (_menhir_stack, _menhir_s) = _menhir_stack in
                      let e = _v in
                      let _v = _menhir_action_2 e in
                      let _menhir_stack = MenhirCell1_instruction (_menhir_stack, _menhir_s, _v) in
                      (match (_tok : MenhirBasics.token) with
                      | PRINT ->
                          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
                      | END ->
                          let _v_0 = _menhir_action_3 () in
                          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0
                      | _ ->
                          _eRR ())
                  | _ ->
                      _eRR ())
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  let _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_program =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | MAIN ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | BEGIN ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | PRINT ->
                  _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState02
              | END ->
                  let _v = _menhir_action_3 () in
                  _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
end

let program =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_program v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
