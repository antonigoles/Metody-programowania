module type PRIO_QUEUE = sig
  type ('a, 'b) pq
  val empty : ('a, 'b) pq
  val insert : 'a -> 'b -> ('a, 'b) pq -> ('a, 'b) pq
  val pop : ('a, 'b) pq -> ('a, 'b) pq
  val min_with_prio : ('a, 'b) pq -> ('a * 'b) option
  val list_of_pq: ('a, 'b) pq -> ('a * 'b) list
end

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
        if p1 <= p2 
        then (v1, p1, l1, r1, h2) 
        else (v2, p2, l2, r2, h1)
      ) in
      make_node p e hl (heap_merge hr h)
end

module HeapPrioQueue : PRIO_QUEUE = struct
  open LeftistHeap
  type ('a, 'b) pq = ('a, 'b) heap
  let empty = HLeaf
  let insert p v h = heap_merge h (HNode (1, HLeaf, p, v, HLeaf));;
  let pop = function
  | HLeaf -> HLeaf
  | HNode (_,l,_,_,r) -> heap_merge l r;;
  let min_with_prio = function
  | HLeaf -> None
  | HNode (_,_,p,v,_) -> Some (p,v);; 

  let rec list_of_pq = function
  | HLeaf -> []
  | HNode (_,l,p,v,r) -> [(p,v)] @ list_of_pq (heap_merge l r) 
end

module ListPrioQueue : PRIO_QUEUE = struct
  type ('a, 'b) pq = ('a * 'b) list

  let empty = []
  let rec insert a x q = match q with
  | [] -> [a, x]
  | (b, y) :: ys -> if a < b then (a, x) :: q else (b, y) :: insert a x ys
  let pop q = List.tl q
  let min_with_prio = function 
  | [] -> None
  | q -> Some (List.hd q)
  let list_of_pq pq = pq
end

module PQSort (PQ: PRIO_QUEUE) = struct 
  let pqsort xs = 
    let rec pq_of_list = function
      | [] -> PQ.empty
      | xe :: xs -> PQ.insert xe xe (pq_of_list xs)
    in xs |> pq_of_list |> PQ.list_of_pq;;
end

module HeapPQSort = PQSort(HeapPrioQueue);;
module ListPQSort = PQSort(ListPrioQueue);;

HeapPQSort.pqsort [4;2;9;1;6;0;0;8; -2; 232];;
ListPQSort.pqsort [4;2;9;1;6;0;0;8];;