module LeftistHeap = struct
  type ('a , 'b ) heap =
    | HLeaf
    | HNode of int * ('a , 'b ) heap * 'a * 'b * ('a , 'b ) heap

  let rank = function HLeaf -> 0 | HNode (n , _ , _ , _ , _ ) -> n
  
  let heap_ordered p = function
    | HLeaf -> true
    | HNode (_ , _ , p', _ , _ ) -> p <= p'

  let rec is_valid = function
    | HLeaf -> true
    | HNode (n , l , p , v , r ) ->
      rank r <= rank l
      && rank r + 1 = n
      && heap_ordered p l
      && heap_ordered p r
      && is_valid l
      && is_valid r

  let make_node p v l r = 
    let rr = rank r in let rl = rank l in
    if rl >= rr
    then HNode (rr + 1, l, p, v, r)
    else HNode (rl + 1, r, p, v, l)
  
  let rec heap_merge h1 h2 = 
    match (h1, h2) with 
    | (HLeaf, _) -> h2
    | (_, HLeaf) -> h1
    | (HNode (n1,l1,p1,v1,r1), HNode (n2,l2,p2,v2,r2)) -> 
      let (e, p, hl, hr, h) = (
        if p1 > p2 
        then (v2, p2, l2, r2, h1) 
        else (v1, p1, l1, l2, h2)
      ) in
      make_node p e hl (heap_merge hr h)
end

module type PRIO_QUEUE = sig
  type ('a, 'b) pq
  
  val empty : ('a, 'b) pq
  val insert : 'a -> 'b -> ('a, 'b) pq -> ('a, 'b) pq
  val pop : ('a, 'b) pq -> ('a, 'b) pq
  val min_with_prio : ('a, 'b) pq -> 'a * 'b
end

module HeapPrioQueue = struct
  
end