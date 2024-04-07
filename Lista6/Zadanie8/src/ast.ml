(* abstract syntax tree *)

type bop = Mult | Div | Add | Sub | Eq

type lazylop = AND | OR

type expr =
  | Int of int
  | Bool of bool
  | Binop of bop * expr * expr
  | LazyLOP of lazylop * expr * expr
  | If of expr * expr * expr
                               
