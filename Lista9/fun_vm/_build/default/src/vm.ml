open Ast

type cmd =
  | PushInt of int
  | PushBool of bool
  | Prim of bop
  | CondJmp of cmd list * cmd list
  | Grab           (* wstaw wartosc ze stosu do srodowisko *)
  | Access of int  (* wstaw wartosc ze srodowiska na stos *)
  | EndLet
  | PushClo of cmd list
  | Call
  | Return
            
type vm_value =
  | VMInt of int
  | VMBool of bool
  | VMClosure of cmd list * vm_value list
  | VMRetAddr of cmd list * vm_value list

let eval_vm_op (op : bop) (v1 : vm_value) (v2 : vm_value) : vm_value =
  match op, v1, v2 with
  | Add,  VMInt i1, VMInt i2 -> VMInt (i1 + i2)
  | Sub,  VMInt i1, VMInt i2 -> VMInt (i1 - i2)
  | Mult, VMInt i1, VMInt i2 -> VMInt (i1 * i2)
  | Div,  VMInt i1, VMInt i2 -> VMInt (i1 / i2)
  | Eq,   VMInt i1, VMInt i2 -> VMBool (i1 = i2)
  | Lt,   VMInt i1, VMInt i2 -> VMBool (i1 < i2)
  | Gt,   VMInt i1, VMInt i2 -> VMBool (i1 > i2)
  | Leq,  VMInt i1, VMInt i2 -> VMBool (i1 <= i2)
  | Geq,  VMInt i1, VMInt i2 -> VMBool (i1 >= i2)
  | Neq,  VMInt i1, VMInt i2 -> VMBool (i1 <> i2)
  | _ -> failwith "type error"

let rec exec (p : cmd list) (s : vm_value list) (env : vm_value list) : vm_value =
  match p, s with
  | [], [v] -> v
  | PushInt n :: p', _ -> exec p' (VMInt n :: s) env
  | PushBool b :: p', _ -> exec p' (VMBool b :: s) env
  | Prim op :: p', (v1 :: v2 :: s) -> exec p' (eval_vm_op op v2 v1 :: s) env
  | CondJmp (t, e) :: p', VMBool v :: s' -> if v then exec (t @ p') s' env
                                            else exec (e @ p') s' env
  | Grab :: p', v :: s' -> exec p' s' (v :: env)
  | Access n :: p', _ -> exec p' (List.nth env n :: s) env
  | EndLet :: p', _ -> exec p' s (List.tl env)
  | PushClo q :: p', _ -> exec p' (VMClosure (q, env) :: s) env
  | Call :: p', VMClosure (q, env') :: v :: s' ->
     exec q (VMRetAddr (p', env) :: s') (v :: env')
  | Return :: _, v :: VMRetAddr (p, env') :: s' -> exec p (v :: s') env'
  | _, _ -> failwith "error"
       
let exe p = exec p [] []


module T = struct
  type cmd =
  | PushInt of int
  | PushBool of bool
  | Prim of bop
  | Jmp of string
  | CondJmp of string
  | Grab
  | Access of int
  | EndLet
  | PushClo of string
  | Call
  | Return
  | Lbl of string
end

let flatten (c: cmd list) : T.cmd list =
  let counter = ref 0 in 
  let next_label_suffix = fun () -> counter := (!counter) + 1; string_of_int(!counter) in
  let rec inner (c: cmd list) : T.cmd list =
    match c with 
    | [] -> []
    | PushInt n :: c' -> [T.PushInt n] @ (inner c')
    | PushBool b :: c' -> [T.PushBool b] @ (inner c')
    | Prim bop :: c' -> [T.Prim bop] @ (inner c')
    | CondJmp(c1, c2) :: c' -> 
      let label1, label2, label3 = next_label_suffix (), next_label_suffix (), next_label_suffix ()  in 
      [T.Lbl label1] @ (inner c1) @ [T.Jmp label3] @ [T.Lbl label2] @ (inner c2) @ [T.Jmp label3] 
      @ [T.CondJmp label1] @ [T.Jmp label2] @ [T.Lbl label3] @ (inner c')
    | Grab :: c' -> [T.Grab] @ (inner c')
    | Access n :: c' -> [T.Access n] @ (inner c')
    | EndLet :: c' -> [T.EndLet] @ (inner c')
    | PushClo c :: Return :: c' -> 
        let label = next_label_suffix () 
        in [T.Lbl label] @ (inner c) @ [T.PushClo label] @ (inner c')
    | Call :: c' -> [T.Call] @ (inner c')
    | Return :: c' -> [T.Return] @ (inner c')
    | _ -> failwith "error"
  in inner c;;