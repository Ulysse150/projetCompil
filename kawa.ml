(**
   Kawa : un petit langage à objets inspiré de Java
 *)

(* Types déclarés pour les attributs, pour les variables, et pour les 
   paramètres et résultats des méthodes. *)
type typ =
  | TVoid
  | TInt
  | TBool
  | TClass of string

let typ_to_string = function
  | TVoid    -> "void"
  | TInt     -> "int"
  | TBool    -> "bool"
  | TClass c -> c


(*Transforme une liste de (t, [s1,..., sn])
ou t est le type des variables s1, ..., sn
pour les variables declarees en serie
et les transforme en [(s1, t), ... , (sn, t)]
*)

let transform_decl decls = 
  let t, l = decls in 
  List.map (fun s -> (s, t)) l






type unop  = Opp | Not
type binop = Add | Sub | Mul | Div | Mod
           | Inf | Infeq  | Sup | Supeq | Eq  | Neq
           | And | Or  | Pow | Steq | Stdiff

           
let binop_to_string  = 
  function 
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Inf -> "<"
  | Infeq-> "<="
  | Sup -> ">"
  | Supeq->">="
  | Eq -> "=="
  | Neq -> "!="
  | And -> "&&"
  | Or -> "||"
  | Pow -> "^"
  | Steq -> "==="
  | Stdiff -> "=/="


(* Expressions *)
type expr =
  (* Base arithmétique *)
  | Int    of int
  | Bool   of bool
  | Unop   of unop * expr
  | Binop  of binop * expr * expr
  (* Accès à une variable ou un attribut *)
  | Get      of mem_access
  (* Objet courant *)
  | This
  (* Création d'un nouvel objet *)
  | New      of string
  | NewCstr  of string * expr list
  (* Appel de méthode *)
  | MethCall of expr * string * expr list
  | Instof of expr * typ
  | Super of string * expr list
  (*Instance of*)

(* Accès mémoire : variable ou attribut d'un objet *)
and mem_access =
  | Var   of string
  | Field of expr (* objet *) * string (* nom d'un attribut *)

let mem_access_string  =
  function
  | Var v -> v
  | Field(e, s) -> Printf.sprintf"%s"  s


(* Instructions *)
type instr =
  (* Affichage d'un entier *)
  | Print  of expr
  (* Écriture dans une variable ou un attribut *)
  | Set    of mem_access * expr
  (* Structures de contrôle usuelles *)
  | If     of expr * seq * seq
  | While  of expr * seq
  (* Fin d'une fonction *)
  | Return of expr
  (* Expression utilisée comme instruction *)
  | Expr   of expr

and seq = instr list

(* Définition de méthode 

   Syntaxe : method <type de retour> <nom> (<params>) { ... }

   Le corps de la méthode est similaire au corps d'une fonction. *)
type method_def = {
    method_name: string;
    code: seq;
    params: (string * typ) list;
    locals: (string * typ) list;
    return: typ;
  }
        
(* Définition de classe 

   Syntaxe : class <nom de la classe> { ... }
        ou : class <nom de la classe> extends <nom de la classe mère> { ... }

   On considère que toute classe C contient une définition de méthode de nom
   "constructor" et de type de retour void, qui initialise les champs du 
   paramètre implicite this. *)
type class_def = {
    class_name: string;
    attributes: (string * typ) list;
    methods: method_def list;
    parent: string option;
  }

(* Programme complet : variables globales, classes, et une séquence 
   d'instructions *)
type program = {
    classes: class_def list;
    globals: (string * typ ) list;
    main: seq;
  }



