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

let rec to_rpn (e : expr) : rpn =
  match e with
  | Int n -> [Push n]
  | Add (e1, e2) -> to_rpn e1 @ to_rpn e2 @ [RAdd]
  | Mult (e1, e2) -> to_rpn e1 @ to_rpn e2 @ [RMult]



let rec random_expr (max_depth: int) : expr = 
  if max_depth = 0 
    then Int( Random.int 100 )
  else if max_depth > 0 then 
    let choice = Random.int 3 in
    match choice with 
    | 2 -> Mult(random_expr (max_depth-1), random_expr (max_depth-1))
    | 1 -> Add(random_expr (max_depth-1), random_expr (max_depth-1))
    | _ -> Int( Random.int 100 )
  else failwith "Depth error!";;

let rec expr_equal e1 e2 =
  match (e1, e2) with
  | Int a, Int b -> a = b
  | Add(a,b), Add(c,d) -> (expr_equal a c) && (expr_equal b d)
  | Mult(a,b), Mult(c,d) -> (expr_equal a c) && (expr_equal b d)
  | _ -> false

let rec test (max_depth: int) (n: int) : bool = 
  if n = 0 then true 
  else let e = random_expr max_depth in 
    (expr_equal (from_rpn (to_rpn e)) e) && (test max_depth (n-1));;

test 8 1240;;