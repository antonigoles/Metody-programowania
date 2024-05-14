type expr =
  | Int of int
  | Add of expr * expr
  | Mult of expr * expr

type rpn_cmd =
  | Push of int
  | RAdd
  | RMult

type rpn = rpn_cmd list


let from_rpn (r: rpn) : expr = 
  let rec f (r: rpn) (el: expr list) : expr =
    match (r, el) with
    | Push(a) :: r', _ -> f r' ([Int(a)] @ el)
    | RAdd :: r', e1 :: e2 :: el' -> f r' ( [Add(e2, e1)] @ el') 
    | RMult :: r', e1 :: e2 :: el' -> f r' ( [Mult(e2, e1)] @ el')
    | [], [e] -> e
    | _ -> failwith "Oh no"
  in f r [];;


from_rpn [Push(1); Push(2); RAdd; Push(1); Push(2); RMult; RMult];;