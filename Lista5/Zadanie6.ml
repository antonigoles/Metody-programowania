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

to_nnf (Neg(Conj(Var(3), Disj(Neg(Var(2)), Var(3)))));;