let rec __suffixes xs acc = 
  if 0 >= (List.length xs) then (acc @ [[]]) 
  else __suffixes (List.tl xs) (acc @ [xs]);;

let suffixes xs = __suffixes xs [];;
suffixes [1;2;3;4];;