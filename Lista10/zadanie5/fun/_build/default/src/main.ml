open Ast

let parse (s : string) : expr =
  Parser.prog Lexer.read (Lexing.from_string s)

module M = Map.Make(String)

type env = value M.t

and value =
  | VInt of int
  | VBool of bool
  | VClosure of ident * expr * env
  | VRef of ident

let eval_op (op : bop) (v1 : value) (v2 : value) : value =
  match op, v1, v2 with
  | Add,  VInt i1, VInt i2 -> VInt (i1 + i2)
  | Sub,  VInt i1, VInt i2 -> VInt (i1 - i2)
  | Mult, VInt i1, VInt i2 -> VInt (i1 * i2)
  | Div,  VInt i1, VInt i2 -> VInt (i1 / i2)
  | Eq,   VInt i1, VInt i2 -> VBool (i1 = i2)
  | Lt,   VInt i1, VInt i2 -> VBool (i1 < i2)
  | Gt,   VInt i1, VInt i2 -> VBool (i1 > i2)
  | Leq,  VInt i1, VInt i2 -> VBool (i1 <= i2)
  | Geq,  VInt i1, VInt i2 -> VBool (i1 >= i2)
  | Neq,  VInt i1, VInt i2 -> VBool (i1 <> i2)
  | _ -> failwith "type error"

let next_ref_address = 
  let x = ref 0 
  in fun _ -> x := !x + 1; "ref-addr-"^(string_of_int !x);;

let rec eval_env (env : env) (e : expr) (rs: env) : (env * value) =
  match e with
  | Int n -> (rs, VInt n)
  | Bool b -> (rs, VBool b)
  | If (p, t, e) ->
      (match eval_env env p rs with
      | rs, VBool true -> eval_env env t rs
      | rs, VBool false -> eval_env env e rs
      | _ -> failwith "type error")
  | Binop (And, e1, e2) ->
      (match eval_env env e1 rs with
      | rs, VBool true -> eval_env env e2 rs
      | rs, VBool false -> (rs, VBool false)
      | _ -> failwith "type error")
  | Binop (Or, e1, e2) ->
      (match eval_env env e1 rs with
      | rs, VBool false -> eval_env env e2 rs
      | rs, VBool true -> (rs, VBool true)
      | _ -> failwith "type error")
  | Binop (op, e1, e2) -> 
    let (rs,l) = (eval_env env e1 rs) in 
    let (rs,r) = (eval_env env e2 rs) in
    (rs, eval_op op l r)
  | Let (x, e1, e2) ->
      let (rs,r) = eval_env env e1 rs in
      let new_env = M.add x r env in
      eval_env new_env e2 rs
  | Var x ->
      (match M.find_opt x env with
      | Some v -> (rs, v)
      | None -> failwith ("unbound value " ^ x))
  | Fun (x, e) -> (rs, VClosure (x, e, env))
  | App (e1, e2) ->
      let ((_,ev1), (_,ev2)) = (eval_env env e1 rs, eval_env env e2 rs) in
      (match  ev1, ev2 with
      | VClosure (x, body, clo_env), v -> eval_env (M.add x v clo_env) body rs
      | _, _ -> failwith "type error")
  | Ref e -> let (addr, (rs, value)) = (next_ref_address (), eval_env env e rs) in 
    (M.add addr value rs, VRef(addr))
  | DeRef e -> 
      (match (eval_env env e rs) with 
      | _, VRef (addr) -> 
        (match M.find_opt addr rs with
        | Some v -> (rs, v)
        | None -> failwith ("Dereferencing error at DeRef::M.find_opt"))
      | _ -> failwith "Dereferencing error at DeRef")
  | RefAssignDeRef (e1, e2, e3) ->
      let (rs, ev1) = (eval_env env e1 rs) in
      let (rs, ev2) = (eval_env env e2 rs) in
      (match ev1, ev2 with
      | VRef(x), e2 -> 
        let newrs = (M.add x e2 rs) in 
        (eval_env env e3 newrs)
      | _ -> failwith "Dereferencing error at RefAssignDeRef")

let eval_env_clear tokens = let (_,v) = eval_env M.empty tokens M.empty in v;;

let initial_env = M.empty
  |> M.add "abs" (parse "fun x -> if x < 0 then 0 - x else x" |> eval_env_clear)
  |> M.add "mod" (parse "fun x -> fun y -> x - (x / y) * y" |> eval_env_clear) 
  |> M.add "fix" (parse "fun f -> (fun x -> fun y -> f (x x) y) (fun x -> fun y -> f (x x) y)" |> eval_env_clear)

let eval = eval_env initial_env

let interp (s : string) : value =
  let (_, v) = (eval (parse s) M.empty) in v
