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

let exec_prog (p: program): unit =
  let env = Hashtbl.create 16 in
  List.iter (fun (x, _) -> Hashtbl.add env x Null) p.globals;
  
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


      | Unop(Opp, e)-> VInt(-evali e)

      | _ -> failwith "case not implemented in eval"
    

    in
  




    let rec exec (i: instr): unit = match i with
      | Print e -> Printf.printf "%d\n" (evali e)
      | _ -> failwith "case not implemented in exec"

    and exec_seq s = 
      List.iter exec s
    in

    exec_seq s
  in
  
  exec_seq p.main (Hashtbl.create 1)
