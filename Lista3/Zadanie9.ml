type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let t = Node (Node (Leaf, 2, Leaf), 5, Node (Node (Leaf, 6, Node (Leaf, 7, Leaf)), 8, Node (Leaf, 9, Leaf)));;


let rec insert_bst_into_bst st t = 
  match st with 
  | Leaf -> t
  | Node(_, v, _) ->
    match t with
    | Leaf -> st
    | Node(l, v2, r) -> 
      if v > v2 then Node(l, v2, (insert_bst_into_bst st r))
      else Node((insert_bst_into_bst st l), v2, r);;



let rec find_branches_to_reinsert x (t: 't tree) =
  match t with
  | Leaf -> (Leaf, Leaf)
  | Node (left, value, right) -> 
    if value = x then (left, right)
    else if value < x then find_branches_to_reinsert x right
    else find_branches_to_reinsert x left;;

let rec delete_witout_insertion x (t: 't tree) = 
    match t with
    | Leaf -> t
    | Node(left, value, right) -> 
      if value = x then Leaf
      else if value < x then Node( left, value, delete_witout_insertion x right )
      else Node( delete_witout_insertion x left, value, right );;

let delete x (t: 't tree) = 
  let ut = delete_witout_insertion x t in 
  let (bleft, bright) = find_branches_to_reinsert x t in
  (insert_bst_into_bst bleft (insert_bst_into_bst bright ut));;

delete 5 t;;
(* Node (Leaf, 2, Node (Node (Leaf, 6, Node (Leaf, 7, Leaf)), 8, Node (Leaf, 9, Leaf))) *)
delete 8 t;;

(* delete_witout_insertion 8 t;; *)
(* find_branches_to_reinsert 8 t;; *)