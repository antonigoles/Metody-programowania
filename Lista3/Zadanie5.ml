type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let t =
  Node (Node (Leaf , 2, Leaf ), 5, Node ((Node (Leaf , 6, Leaf )), 8, (Node (Leaf , 9, Leaf ))));;

let rec insert_bst e (t: 'a tree) = 
  match t with
  | Leaf -> Node(Leaf, e, Leaf)
  | Node (l, x, r) -> 
    if x < e then Node (l, x, (insert_bst e r) )
    else if x > e then Node ((insert_bst e l), x, r )
    else Node (l, x, r );;

insert_bst 6 t;;

(* Node (Node (Leaf, 2, Leaf), 5, Node (Node (Leaf, 6, Node (Leaf, 7, Leaf)), 8, Node (Leaf, 9, Leaf))) *)