open Kawa

type value =
  | VInt  of int
  | VBool of bool
  | VObj  of obj
  | Null
and obj = {
  cls:    string;
  fields: (string, value) Hashtbl.t;
}

exception Error of string
exception Return of value

let valueToString v = 
  match v with 
  | VInt va -> Printf.sprintf"%d" va
  | VBool b -> Printf.sprintf"%b" b 
  | Null -> Printf.sprintf"null"
  | VObj o -> Printf.sprintf"%s" o.cls 


let print_variables env = 
  Hashtbl.iter (fun c (typ, v) ->
    match typ, v with 
     | TInt, _-> Printf.printf"(%s : int %s)" c (valueToString v)
     | TBool, _ -> Printf.printf"(%s : bool %s)" c (valueToString v)
     | _ -> ()
  ) env ;
  Printf.printf"\n"


let exec_prog (p: program): unit =
  let env = Hashtbl.create 16 in
  List.iter (fun (id, typ) -> Hashtbl.add env id (typ, Null)) p.globals;
  let rec pow a n = 
    match n with
    | 0 -> 1
    | 1 -> a
    | b when b < 0 -> failwith"Puissance negative impossible seuls entiers geres"
    | _ -> match n mod 2 with
      | 0 -> pow (a*a) (n/2)
      | 1 -> a*pow a (n - 1);
      | n -> failwith"Impossible";
  in
  let rec eval_call f this args =
    failwith "eval_call not implemented"

  and exec_seq s lenv =
    let rec evali e = match eval e with
      | VInt n -> n
      | _ -> assert false
    and evalb e = match eval e with
      | VBool b -> b
      | _ -> assert false
    and evalo e = match eval e with
      | VObj o -> o
      | _ -> assert false
        
    and eval (e: expr): value = match e with
      | Int n  -> VInt n
      | Bool b -> VBool(b)

      |   Binop(Mul, e1 ,e2) ->
        VInt( evali e1 *  evali e2)

      | Binop(Div, e1 ,e2) ->
        VInt( evali e1 /  evali e2)

      |Binop(Pow, e1, e2) -> 
        VInt(pow (evali e1) (evali e2))
        
        | Binop(Add, e1 ,e2) ->
          VInt( evali e1 +  evali e2)
  
        |  Binop(Sub, e1 ,e2) ->
          VInt( evali e1 -  evali e2)
        | Binop(Mod, e1, e2) -> 
          VInt((evali e1) mod (evali e2))

        | Binop(And, e1, e2) -> 
          VBool((evalb e1) && (evalb e2))
          
        | Binop(Or, e1, e2) -> 
          VBool((evalb e1) || (evalb e2))

        | Binop(Sup, e1, e2) ->
          VBool((evali e1) > (evali e2) )

        | Binop(Supeq, e1, e2) -> 
          VBool((evali e1) >= (evali e2) )
        | Binop(Inf, e1, e2) -> 
          VBool((evali e1) < (evali e2) )

        | Binop(Infeq, e1, e2) -> 
          VBool((evali e1) <= (evali e2) )
          
        |Binop(Eq, e1, e2) -> 
          VBool((eval e1) = (eval e2))

        |Binop(Neq, e1, e2) -> 
          VBool((eval e1) <> (eval e2))

      | Unop(Opp, e)-> VInt(-evali e)
      | Unop(Not, b) -> 
        VBool(not(evalb (b)))

      | Get(m) -> snd(Hashtbl.find env (mem_access_string m))

      
      | _ -> failwith "case not implemented in eval"
    

    in
  

    let exec_set mem e =
      let name = match mem with 
      | Var v -> v 
      | Field(a, b)-> failwith"Not implemented yet"
      in
      let t = fst (Hashtbl.find env name) in

      Hashtbl.replace env name (t, eval e);
    in


    let rec exec (i: instr): unit = match i with
      | Print e -> Printf.printf "%d\n" (evali e)
      | Set(m, e)-> exec_set m e;
        (*On suppose que le typechecker est passe*)
        (*Donc la variable m existe et le type passe dans e est bon*)

          () 
      | If(cond, b1, b2) -> (
        match evalb cond with 
        | true -> exec_seq b1 ;
        | false -> exec_seq b2; )

      | While(cond, block) -> execWhile cond block

      | _ -> failwith "case not implemented in exec"

    and exec_seq s = 
      List.iter exec s
    
    and execWhile cond block  =
      match evalb cond with 
      | true -> exec_seq block; execWhile cond block 
      | false -> ()
    in

    exec_seq s
  in
  
  exec_seq p.main (Hashtbl.create 1);
  print_variables env
