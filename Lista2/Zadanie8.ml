let is_empty xs = 
  match xs with
  | [] -> true
  | _ -> false;;

let rec __min_idx xs acc idx n = 
  match xs with 
  | [] -> idx
  | x :: xs when acc > x -> __min_idx xs x n (n+1)
  | x :: xs -> __min_idx xs acc idx (n+1);;
    
let rec min_idx xs = __min_idx xs (Int.max_int) 0 0;; 


let rec __select xs n l = 
  if n <= 0 
    then ((List.hd xs), (List.tl xs)@l ) 
  else __select (List.tl xs) (n-1) (l@[(List.hd xs)]);;

let rec select xs = __select xs (min_idx xs) [];;

let rec __select_sort xs sorted = 
  if (is_empty xs) 
  then sorted 
  else let (e, nxs) = (select xs) in (__select_sort nxs (sorted@[e]));;

let rec select_sort xs = (__select_sort xs []);;

select_sort [7;1;6;9;12;4];;
select_sort [1;5;6;1;7;5];;
select_sort [2;3;5;];;