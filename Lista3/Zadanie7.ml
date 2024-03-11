type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree;;

let t = Node (Node (Leaf, 2, Leaf), 5, Node (Node (Leaf, 6, Node (Leaf, 7, Leaf)), 8, Node (Leaf, 9, Leaf)));;

let rec flat_append t xs = 
  match t with
  | Leaf -> xs
  | Node(left, x, right) -> flat_append left (x :: flat_append right xs);;

flat_append t [1; 2; 3];;

let flatten t = flat_append t [];;

flatten t;;