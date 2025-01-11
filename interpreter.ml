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


let copyObjet obj = 
  {cls = obj.cls; fields = Hashtbl.copy obj.fields}

let copyValue v = match v with 
 | VObj o -> VObj (copyObjet o)
 | _ -> v




let getAttributes name env = 
 
  match Hashtbl.find env name with 
  | (TClass(s), VObj(ob)) -> ob.fields
  | _ -> failwith"No attributes"
  
let hashToList hash =

  Hashtbl.fold (fun k d acc -> d::acc   ) hash [] 
  
(*Permet d'obtenir touts les parents d une classe*)

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








exception Error of string
exception Return of value


let envFromDecl varDecl = 
  let env = Hashtbl.create 16 in 
  List.iter ( fun (s, t, v) -> Hashtbl.add env s (t, v)) varDecl;
  env



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

    let rec getHash m env= 

      match m with 
      | Var v -> (match snd(Hashtbl.find env v)  with
                    | VObj o -> o.fields
                    | _ -> failwith"Imposible1"
      )
      | Field(Get(e), x) -> 
        (match (Hashtbl.find (getHash e env) x) with 
        | VObj ob -> ob.fields
        | __ -> failwith"Only objects have attributes")
      | _ -> failwith"Impossible2"

    in

    let exec_get mem lenv =
    match mem with 
    | Var v -> snd(Hashtbl.find lenv (mem_access_string mem))
    | Field(Get(expr), x) -> let hash = getHash expr lenv in 
        Hashtbl.find hash x 
    | Field(This, x) -> 
      (match snd(Hashtbl.find lenv "this")
      with 
      |  VObj o -> Hashtbl.find o.fields x
      | _ ->failwith"Cant do this of something that is not an object" )
      
     
    | _ ->  Printf.printf"%s" (mem_access_string mem) ;failwith"e"

    in
  let rec exec_seq s lenv =
    let rec evali e = match eval e with
      | VInt n -> n
      | _ -> assert false
    and evalb e = match eval e with
      | VBool b -> b
      | _ -> assert false
    and evalo e = match eval e with
      | VObj o -> o
      | _ -> assert false
        
    and eval_call f this args = 
      (* Évaluer l'objet sur lequel la méthode est appelée *)
      let instance =  copyObjet(evalo this) in
      let className = instance.cls in
      (* Rechercher la définition de la classe de l'objet *)
      (* Rechercher la méthode à appeler dans la classe *)

      let methods = getMethods className p.classes in

      let method_def = List.find (fun m -> m.method_name = f) methods in
      (* Évaluer les arguments de la méthode *)
      let params = List.map eval args in 
      (* Créer l'environnement local de la méthode *)
      let locals = Hashtbl.create 16 in 
      
      Hashtbl.iter (fun k (s, t) -> Hashtbl.replace locals k (s, t)) lenv;
      (*let () = match this with
      | Get(Var(str)) -> 
      | _ -> Hashtbl.iter (fun k (s, t) -> Hashtbl.replace locals k (s, copyValue(t))) lenv;*)

    
      
      let () = 
      (* Ajouter l'objet actuel sous le nom "this" *)
      Hashtbl.replace locals "this" ((TClass(className)), VObj(instance))in
      (* Associer les paramètres évalués aux noms des arguments *)
      let () = List.iter2 (fun (s, ty) v -> Hashtbl.replace locals s (ty, copyValue(v)) ) method_def.params params in

      let locals_rec = Hashtbl.copy locals in
     (* Avant l'appel de la méthode *)

      let valR = 
        try 
          exec_seq method_def.code locals;
          Null
        with 
        | Return v -> v
      in

      
      let refe = 
        match this with 
        | Get(Var(s)) -> Some s 
        | _ -> None in 
  

      (* Mise à jour de l'objet this s'il a été modifié *)
      let () = 
      match refe with
      | Some str ->
          let updated_this = Hashtbl.find locals_rec "this" in
          Hashtbl.replace lenv str updated_this
          | None -> () in

    

     
      valR

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

      | Get(m) -> exec_get m lenv
        
      | New s -> 
        (*let cl = List.find (fun c -> c.class_name = s) p.classes in*) 
        let hash = Hashtbl.create 16 in 

        
        let att = getAttribs s p.classes in

        
        List.iter ( fun (s, t) -> Hashtbl.replace hash s  Null) att ;


        

        VObj({cls = s; fields= hash})


      | MethCall(obj, id, args) -> eval_call id obj args

      | NewCstr(s, exprs) ->

          let obj = eval (New(s)) in 

          let instance = match obj with
          | VObj o -> o 
          | _ -> failwith "Appel de fonction sur autre chose qu'objet"
      in

          let className = instance.cls in
          (* Rechercher la définition de la classe de l'objet *)
          let cl = List.find (fun cl -> cl.class_name = className) p.classes in
          (* Rechercher la méthode à appeler dans la classe *)
          let method_def = List.find (fun m -> m.method_name = "constructor") cl.methods in
          (* Évaluer les arguments de la méthode *)
          let params = List.map eval exprs in 
          (* Créer l'environnement local de la méthode *)
          let locals = Hashtbl.create 16 in 
          let () = 
          (* Ajouter l'objet actuel sous le nom "this" *)
          Hashtbl.add locals "this" ((TClass(className)), VObj(instance))in

          

          (* Associer les paramètres évalués aux noms des arguments *)
          let () = List.iter2 (fun (s, ty) v -> Hashtbl.replace locals s (ty, v) ) method_def.params params in
          let () = 
            try 
               exec_seq method_def.code locals
            with 
            | _ -> failwith"Un consctructeur ne renvoie rien"
          in
          VObj(instance)


      | This-> (*On suppose que l'on est dans une methode*)
         snd(Hashtbl.find lenv "this")

    and exec_set mem e =
      
      let valeur = eval e in
      match mem with 
      | Var v -> Hashtbl.replace lenv v (fst(Hashtbl.find lenv v), valeur)
      | Field(Get(expr), x) -> 
        (let hash = getHash expr lenv in
          Hashtbl.replace hash x valeur
        )
      |  Field(This, x) -> 
        (match snd(Hashtbl.find lenv "this")
        with 
        |  VObj o -> Hashtbl.replace o.fields x valeur
        | _ ->failwith"Cant do this of something that is not an object" )
        
      | _ -> failwith"Impossible"



      (*let name = match mem with 
      | Var v -> v 
      | Field(a, b)-> failwith"Not implemented yet"
      in
      let t = fst (Hashtbl.find env name) in

      Hashtbl.replace env name (t, eval e);*)
    


      and exec (i: instr): unit = match i with
      | Print e -> Printf.printf "%d\n" (evali e)
      | Set(m, e) -> exec_set m e
      | If(cond, b1, b2) -> (
          if evalb cond then execseq b1
          else execseq b2
        )
      | While(cond, block) -> execWhile cond block
      | Return e -> raise (Return (eval e))
      | Expr e -> ignore (eval e)
      and execseq s =
        List.iter exec s
      
      and execWhile cond block =
        if evalb cond then (execseq block; execWhile cond block)
        else ()
      in
      
    execseq s
  in
  
  exec_seq p.main env ;
  