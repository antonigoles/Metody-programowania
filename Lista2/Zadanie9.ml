let is_empty xs = 
  match xs with
  | [] -> true
  | _ -> false;;

let rec __split xs l c = 
  if c <= 0 
    then (l, xs) 
  else __split (List.tl xs) (l@[(List.hd xs)]) (c-1);;
  
let rec split xs = __split xs [] ((List.length xs)/2);;


let rec __merge xs ys m = 
  if (is_empty xs) then m @ ys
  else if (is_empty ys) then m @ xs
  else let ex = (List.hd xs) in let ey = (List.hd ys) in
  if ex > ey then __merge xs (List.tl ys) (m @ [ey])
  else __merge (List.tl xs) ys (m @ [ex]);;

let rec merge xs ys = __merge xs ys [];;


let rec merge_sort xs = 
  if (List.length xs) <= 1 then xs 
  else let (l,r) = (split xs) in (merge (merge_sort l) (merge_sort r));;

merge_sort [1293;1;2;4;6;2;1;1;1;18];;