let rec __is_sorted xs acc = 
  if (List.length xs) = 0  then true
  else 
    let fe = (List.hd xs) in 
    if fe >= acc then __is_sorted (List.tl xs) fe
    else false;;

let is_sorted xs = (__is_sorted xs (int_of_float neg_infinity));;

is_sorted [1;2;3;4;8;6];;
is_sorted [1;2;3;4;4;6];;
is_sorted [235;2;3;4;8;6];;