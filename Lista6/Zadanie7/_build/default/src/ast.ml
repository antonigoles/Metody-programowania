(* abstract syntax tree *)

type bop = 
  | Mult 
  | Div 
  | Add 
  | Sub 
  | Eq 
  | NEq 
  | GEq 
  | LEq
  | Gr
  | Le

type expr =
  | Int of int
  | Bool of bool
  | Binop of bop * expr * expr
  | If of expr * expr * expr
                               
