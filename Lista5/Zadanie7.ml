type 'v nnf =
  | NNFLit of bool * 'v
  | NNFConj of 'v nnf * 'v nnf (* AND *)
  | NNFDisj of 'v nnf * 'v nnf (* OR *)

type 'v formula =
  | Var of 'v
  | Neg of 'v formula
  | Conj of 'v formula * 'v formula (* AND *)
  | Disj of 'v formula * 'v formula (* OR *)

let rec neg_nnf = function 
  | NNFLit(b, v) -> NNFLit(not b, v)
  | NNFConj(a, b) -> NNFDisj( (neg_nnf a), (neg_nnf b) ) 
  | NNFDisj(a, b) -> NNFConj( (neg_nnf a), (neg_nnf b) );;
  
let rec to_nnf = function
  | Var(a) -> NNFLit(false, a)
  | Neg(a) -> neg_nnf (to_nnf a)
  | Conj(a, b) -> NNFConj((to_nnf a), (to_nnf b))
  | Disj(a, b) -> NNFDisj((to_nnf a), (to_nnf b));;

let rec eval_nnf f = function
  | NNFLit(b, v) -> if b then not (f v) else (f v)
  | NNFConj(v1, v2) -> (eval_nnf f (v1)) && (eval_nnf f (v2))
  | NNFDisj(v1, v2) -> (eval_nnf f (v1)) || (eval_nnf f (v2))

module Sposob1 = struct
  let eval_formula f v = eval_nnf f (to_nnf v);;
end

(* albo *)

module Sposob2 = struct
  let rec eval_formula f = function
    | Var(a) -> f a
    | Neg(a) -> not (eval_formula f a)
    | Conj(a, b) -> (eval_formula f (a)) && (eval_formula f (b))
    | Disj(a, b) -> (eval_formula f (a)) || (eval_formula f (b))
end

