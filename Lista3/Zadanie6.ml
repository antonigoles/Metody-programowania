type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree;;

let t = Node (Node (Leaf, 2, Leaf), 5, Node (Node (Leaf, 6, Node (Leaf, 7, Leaf)), 8, Node (Leaf, 9, Leaf)));;

let rec fold_tree f a t =
  match t with
  | Leaf -> a
  | Node (l, v, r) -> f (fold_tree f a l) v (fold_tree f a r);;

fold_tree (fun l v r -> l + v + r ) 0 t;; (* test *)

let tree_product t =
  match t with 
  | Leaf -> 0 
  | _ -> fold_tree (fun a b c -> a*b*c) 1 t;;

tree_product t;; (* 5*2*8*6*9*7 = 30240 *)

let tree_flip t = fold_tree (fun l m r -> Node (r, m, l)) Leaf t;;

tree_flip t;;

let max a b = if a > b then a else b;;
let min a b = if a < b then a else b;;

let tree_height t = fold_tree ( fun l m r -> (max l r) + 1 ) 0 t;;

tree_height t;;

let tree_span t = 
  match t with
  | Leaf -> (0,0)
  | Node(l, v, r) -> 
    let tree_min t = fold_tree (fun l v r -> min (min l r) v ) v t in 
    let tree_max t = fold_tree (fun l v r -> max (max l r) v ) v t in
    ((tree_min t), (tree_max t));;
  
tree_span t;;

let preorder t = 
  match t with
  | Leaf -> []
  | Node(a,m,b) -> fold_tree (fun l v r ->  [v] @ l @ r ) [] t;; 

preorder t;;