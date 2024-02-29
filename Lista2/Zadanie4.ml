let rec __mem x xs n = 
  if n >= (List.length xs) 
    then false
  else if (List.nth xs n) = x 
    then true
  else __mem x xs (n+1);; 

let rec mem x xs = (__mem x xs 0);;

mem 1 [1;2;3;4;5;6];;
mem (-1) [1;2;3;4;5;6];;
mem 2 [1;2;3;4;5;6];;