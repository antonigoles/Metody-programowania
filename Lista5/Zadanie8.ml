let rec is_sorted = function
  | [] -> true
  | x :: [] -> true 
  | a :: b :: xs -> 
    if b >= a then is_sorted (b::xs) 
    else false;;

let rec insert x = function
  | [] -> [x]
  | a :: xs -> 
    if a > x then x :: a :: xs 
    else a :: (insert x xs);;


insert 4 [1;2;3;4;6;8;9];;
insert 0 [1;2;3;4;6;8;9];;
insert 2 [1;2;3;4;6;8;9];;
insert 9 [1;2;3;4;6;8;9];;