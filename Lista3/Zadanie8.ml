type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec insert_bst e (t: 'a tree) = 
  match t with
  | Leaf -> Node(Leaf, e, Leaf)
  | Node (l, x, r) -> 
    if x > e then Node ((insert_bst e l), x, r )
    else Node (l, x, (insert_bst e r) );;

let rec flat_append t xs = 
  match t with
  | Leaf -> xs
  | Node(left, x, right) -> flat_append left (x :: flat_append right xs);;

let flatten t = flat_append t [];;

let tree_sort xs = 
  let rec tree_sort_helper xs (t: 't tree) = 
    match xs with
    | [] -> flatten t
    | x :: xs -> tree_sort_helper xs (insert_bst x t)
  in tree_sort_helper xs Leaf;;

tree_sort [4;1;89;3;4;7;1];;
