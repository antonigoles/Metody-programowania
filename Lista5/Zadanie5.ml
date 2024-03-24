type 'v nnf =
  | NNFLit of bool * 'v
  | NNFConj of 'v nnf * 'v nnf (* AND *)
  | NNFDisj of 'v nnf * 'v nnf (* OR *)

let rec eval_nnf f = function
  | NNFLit(b, v) -> if b then not (f v) else (f v)
  | NNFConj(v1, v2) -> (eval_nnf f (v1)) && (eval_nnf f (v2))
  | NNFDisj(v1, v2) -> (eval_nnf f (v1)) || (eval_nnf f (v2))