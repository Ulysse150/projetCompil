open Kawa

exception Error of string
let error s = raise (Error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

let operator_error operator type1 type2 = 
  error(Printf.sprintf "Unsupported operator %s between %s and %s" operator type1 type2)


module Env = Map.Make(String)
type tenv = typ Env.t

let add_env l tenv =
  List.fold_left (fun env (x, t) -> Env.add x t env) tenv l

let typecheck_prog p =
  let tenv = add_env p.globals Env.empty in
  (*let () = Env.iter (fun s a -> Printf.printf"(%s , %s)" s (typ_to_string a)) tenv;
  Printf.printf"\n" in*)



  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error typ_e typ

  and type_expr e tenv = match e with
    | Int _  -> TInt
    | Bool _ -> TBool
    | Unop(Opp, e) -> 
        let t = type_expr e tenv in 
        if t = TInt then TInt else type_error t TInt
    | Unop(Not, e) -> 
        let t = type_expr e tenv in 
        if t = TBool then TBool else type_error t TBool
    | Binop(op, e1, e2) -> type_binop op e1 e2 tenv

    | Get m -> type_mem_access m tenv
    | _ -> failwith "case not implemented in type_expr"

  and type_mem_access m tenv = match m with
    | Var v -> Env.find v tenv
    | _ -> failwith"Not implemented yet"
  

  and type_binop op e1 e2 tenv= 
    match op with 
    | Add | Sub | Mul | Div | Mod | Pow -> 
        let t1 = type_expr e1 tenv in 
        let t2 = type_expr e2 tenv in 
        if (t1 = TInt && t2 = TInt) then TInt else 
          operator_error (binop_to_string op) (typ_to_string t1) (typ_to_string t2)

    | And |  Or -> let t1 = type_expr e1 tenv in 
      let t2 = type_expr e2 tenv in 
      if (t1 = TBool && t2 = TBool) then TBool else 
      operator_error (binop_to_string op) (typ_to_string t1) (typ_to_string t2) 

    | Sup | Supeq | Inf | Infeq -> 
      (*Pour les operateurs >, < <= ou >= *)
      (*L expressions gauche et droite doivent être des entiers*)
      let t1 = type_expr e1 tenv in 
      let t2 = type_expr e2 tenv in 
      if (t1 = TInt && t2 = TInt) then TBool (*Si c est le cas on renvoie booleen*)
      else operator_error (binop_to_string op) (typ_to_string t1) (typ_to_string t2) 

    | Eq | Neq -> 
      (*Pour les symboles != et == t1 et t2 doivent etre de meme type*)
      let t1 = type_expr e1 tenv in 
      let t2 = type_expr e2 tenv in 
      if (t1 = t2) then TBool (*Si c est le cas on renvoie booleen*)
      else operator_error (binop_to_string op) (typ_to_string t1) (typ_to_string t2)
      (*Sinon on renvoie une erreur*) 
  in

  

  let checkSet m e tenv = 
    (*Pour le setter on doit verifier que la variable existe*)
    (*Et que le type de e est bien le meme que celui de la variable*)
    let v = mem_access_string m in
    (*On teste si la variable existe*)
    if Env.mem v tenv then 
      let t = type_expr e  tenv in
      let typ_attendu = Env.find v tenv in 
      if t <> typ_attendu then 
        error(Printf.sprintf"Set problem : %s expected %s got %s" v (typ_to_string typ_attendu) (typ_to_string t))
      else()
    else
      (*Si la variable n existe pas on lance une erreur*)
      error(Printf.sprintf"Variable %s does not exist." v) 


  in

  
  let rec check_instr i ret tenv = match i with
    | Print e -> check e TInt tenv
    | Set(m, e) -> checkSet m e tenv
    | If(cond, block1, block2) -> checkIf cond block1 block2 ret tenv
    | While(cond, blocl) -> checkWhile cond blocl ret tenv
    | _ -> failwith "case not implemented in check_instr"
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  

  and checkIf cond b1 b2 ret tenv= 
      let typeCond = type_expr cond tenv in
      (*On verifie que le type de la condition est un booleen*)
      (*Si ca ne l'est pas on lance une erreur*)
      (*Sinon on verifie les instructions de b1 et b2*)
      if typeCond = TBool then 
        (*On verifie les expressions du if*)
          begin
          check_seq b1  ret tenv ;
          check_seq b2  ret tenv        
          end
      else
        error(Printf.sprintf"Error at if : condition must be a bool not a %s" (typ_to_string typeCond))

    and checkWhile cond b1 ret tenv = 
      let typeCond = type_expr cond tenv in
      if typeCond = TBool then 
        check_seq b1 ret tenv
    else
      error(Printf.sprintf"Error at while : condition must be a bool not a %s" (typ_to_string typeCond))
    in



  check_seq p.main TVoid tenv
