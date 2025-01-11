open Kawa

exception Error of string
let error s = raise (Error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

module Env = Map.Make(String)
type tenv = typ Env.t
           

let hashToList hash =

  Hashtbl.fold (fun k d acc -> d::acc   ) hash [] 


let getParents className allClasses = 
  
  let rec aux cl=
    match cl.parent with 
    | None -> []
    | Some s -> 
      let parent = List.find (fun c -> c.class_name = s) allClasses in 
      parent::(aux parent )
  in
  aux (List.find (fun c -> c.class_name = className) allClasses)

let getMethods class_name allClasses = 
  (*Renvoie une HashMap des methodes d'une classe *)
  let parents = getParents class_name allClasses in 

  let env = Hashtbl.create 16 in 
  let cl = List.find (fun c -> c.class_name = class_name) allClasses in


  List.iter (fun p -> List.iter (fun m -> Hashtbl.replace env m.method_name m) p.methods) parents;
  List.iter (fun m -> Hashtbl.replace env m.method_name m  ) cl.methods;
  hashToList env

let getAttribs class_name allClasses = 
    (*Renvoie une HashMap des methodes d'une classe *)
    let parents = getParents class_name allClasses in 



    let cl = List.find (fun c -> c.class_name = class_name) allClasses in

    let env = Hashtbl.create 16 in 
  
    List.iter (fun p -> List.iter (fun (s,t) -> Hashtbl.replace env s (s,t)) p.attributes) parents;
    List.iter (fun (s, t) -> Hashtbl.replace env s (s, t)  ) cl.attributes;
    hashToList env

(*Sert a verifier si le type calculé est bien le type attendu*)
(* Pour un type primitif on attend le meme*)
(* Pour un type classe, expected doit etre un ancetre de calculated*)
let typageRespecte expected calculated  allClasses =
  if expected = calculated then true
  else

  match expected, calculated with 
  | TClass s1, TClass s2 ->  let ancetres = getParents s2 allClasses in 
                List.exists ( fun cl -> cl.class_name = s1 ) ancetres
  | other , _   -> false




let operator_error operator type1 type2 = 
  error(Printf.sprintf "Unsupported operator %s between %s and %s" operator type1 type2)


let getType s variables = fst(Env.find s variables)  


let int_of_bool b = 
  if b then 1 else 0

(*Compte combien d elements de la liste verifient le predicat f*)
let countF f list = 
  let rec aux ll acc = 
    match ll with 
    | [] -> acc 
    | e::ll -> aux ll (acc + (int_of_bool (f e)))
  in 
  aux list 0



let add_env l tenv =
  List.fold_left (fun env (x, t) -> Env.add x t env) tenv l

let typecheck_prog p =
  let tenv = (add_env p.globals Env.empty) in
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
    | New s -> if (classExists s) then TClass(s) else failwith(Printf.sprintf"Class %s does not exist" s)
    | NewCstr(s, l) -> typeCstr s l tenv
    | This -> (match Env.find_opt "this" tenv  with 
        | None -> failwith("Use of This outside of a class")
        | Some c -> c)
    | MethCall(e, s, l) -> typeMethCall e s l tenv
    



  and classExists s = 
    (* on verifie si la classe s est dans le programme*)
    let rec aux l = 
      match l with 
      | [] -> false
      | cl::ll -> (cl.class_name = s) || aux ll in
    aux  p.classes 
  
  and getClassByName s  = 
    
    List.find_opt (fun f -> f.class_name = s) p.classes
  

  and typeCstr s l env = 
   (*D abord on calcule la classe de s*)
    let classe = getClassByName s  in 
    (*On verifie que cette classe existe*)
    match classe with 
    | None -> failwith(Printf.sprintf"Class %s does not exist" s)
    | Some c -> (*On trouve le constructeur*)
        let constructeur = List.find_opt (fun f -> f.method_name = "constructor")
          c.methods in 
        (match constructeur with 
        | None -> failwith(Printf.sprintf"Class %s does not have a constructor" s)
        (*On verifie qu il ya le bon nombre de parametres et que
                  les valeurs mises en paramètres correspondent au type   *)
        | Some constr -> if ((List.length l) = (List.length constr.params))
          then begin 
            let () = List.iter2 (fun e (s, t) -> check e t env ) l constr.params in
            TClass(s) end
          else
            failwith(Printf.sprintf"Constructor of %s has %d parameters not %d"
                s (List.length constr.params) (List.length l))
            )     
      
        
  and check_mdef mdef mclass env = 
    (*Verifie qu il y n 'a pas de souci avec une methode*)
    (*On verifie que la classe n'apparait pas deux fois*)

    let cl =  TClass(mclass.class_name) in
    (*On ajoute this, les variables locales et les paramètres*)
    
    let myEnv = add_env mdef.locals env in 
    let myEnv = add_env mdef.params myEnv in 
    let myEnv = Env.add "this" cl myEnv in

    (*On verifie que la methode apparait dans les methodes de la classe une fois seulement*)

    if countF (fun f -> f.method_name = mdef.method_name) mclass.methods <> 1 then 
      failwith(Printf.sprintf"Function %s of %s class appears more than 1 time" mdef.method_name mclass.class_name)
    else
      check_seq mdef.code mdef.return myEnv
        
  and check_class cl env = 
      List.iter (fun m -> check_mdef m cl env) cl.methods



  and typeMethCall e s l  env= 
    (*On trouve la classe de l'appellant*)
    let typ = type_expr e env in

    let cl = List.find (fun cl-> TClass(cl.class_name) = typ ) p.classes in
    

    let functions = getMethods cl.class_name p.classes in

    let fonc = List.find_opt (fun f -> f.method_name = s)
    functions in 
  (match fonc with 
  | None -> failwith(Printf.sprintf"Class %s does not have a function named %s" cl.class_name s)
  (*On verifie qu il ya le bon nombre de parametres et que
            les valeurs mises en paramètres correspondent au type   *)
  | Some f -> if ((List.length l) = (List.length f.params))
    then begin 
      let () = List.iter2 (fun e (s, t) -> check e t env ) l f.params in
      f.return end
    else
      failwith(Printf.sprintf"%s  has %d parameters not %d"
           s (List.length f.params) (List.length l))
      )     



  and type_mem_access m tenv = match m with
    | Var v -> if Env.mem v tenv then Env.find v tenv else 
      failwith (Printf.sprintf"Variable %s does not exist" v)
    | Field(e, s) -> 
        let t = type_expr e tenv in (*Le type de la classe*)

        (*On verifie que ce type existe*)
        
        let cl = 
          match List.find_opt (fun c -> TClass(c.class_name) = t) p.classes with
          | Some cl -> cl
          | None -> failwith (Printf.sprintf "Class %s does not exist" (typ_to_string t))
        in
        (*On verifie que l'attribut existe*)

        let att =  getAttribs cl.class_name p.classes in

        (*let par = getParents cl.class_name p.classes in*)
        

        match List.find_opt (fun (str, typ) -> str = s) att with 
        | Some (a, b) -> b
        | None -> failwith(Printf.sprintf"Class %s does not have %s attribute\n" (typ_to_string t) s)
    

          


    
  

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

  
  

  and checkSet m e tenv = 
    (*Pour le setter on doit verifier que la variable existe*)
    (*Et que le type de e est bien le meme que celui de la variable*)

    let v = mem_access_string m in
    (*On teste si la variable existe*)
    let type_attendu = type_mem_access m tenv in 
    let t = type_expr e tenv in
    
    (*let () = (match type_attendu with 
    | TClass s -> Printf.printf" Classe attendue : %s\n" s
    | TInt-> Printf.printf"  Classe attendue int\n";
    | TVoid -> Printf.printf" Classe attendue  void\n";
    | TBool -> Printf.printf" Classe attendue  bool\n";) in


    Printf.printf"Classe calculée : ";
    let () = match  t  with
    | TClass s -> Printf.printf"%s\n" s
    | TInt-> Printf.printf"int\n";
    | TVoid -> Printf.printf"void\n";
    | TBool -> Printf.printf"bool\n" in *)

   


    

  
    if not(typageRespecte type_attendu t p.classes) then 
      error(Printf.sprintf"Set problem : %s expected %s got %s" v (typ_to_string type_attendu) (typ_to_string t))
    else
      if t <> type_attendu then 
        match t with
        | TClass s -> (
          match m with 
          | (Var(str)) -> 
            
            let tenv = Env.add s t (Env.remove s tenv) in 
            ()
          | _ -> ()
        )
        | _ -> ()
        (*if Env.mem v tenv then 
      let t = type_expr e  tenv in
      let typ_attendu = Env.find v tenv in 
      
    else*)

       
  
  

  and  check_instr i ret tenv = match i with
    | Print e -> check e TInt tenv
    | Set(m, e) -> checkSet m e tenv
    | If(cond, block1, block2) -> checkIf cond block1 block2 ret tenv
    | While(cond, blocl) -> checkWhile cond blocl ret tenv
    | Return e -> check e ret tenv
    | Expr e -> check e TVoid tenv
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  

  and checkIf cond b1 b2 ret tenv= 
      let typeCond = type_expr cond tenv in
      (*On verifie que le type de la condition est un booleen*)
      (*Si ca ne l'est pas on lance une erreur*)
      (*Sinon on verifie les instructions de b1 et b2*)
      if typeCond = TBool then 
        (*On verifie les sequences du if et du else*)
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

    
  (* On verifie chaque*)
  List.iter (fun cl -> check_class cl tenv) p.classes;
  check_seq p.main TVoid tenv;
  Env.iter (fun s t -> Printf.printf"%s : %s\n" s (typ_to_string t)) tenv
