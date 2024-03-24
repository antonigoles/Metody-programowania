type 'v nnf =
  | NNFLit of bool * 'v
  | NNFConj of 'v nnf * 'v nnf
  | NNFDisj of 'v nnf * 'v nnf

let rec neg_nnf = function 
  | NNFLit(b, v) -> NNFLit(not b, v)
  | NNFConj(a, b) -> NNFDisj( (neg_nnf a), (neg_nnf b) ) 
  | NNFDisj(a, b) -> NNFConj( (neg_nnf a), (neg_nnf b) );;
  

neg_nnf (neg_nnf (NNFLit(true, None)));;