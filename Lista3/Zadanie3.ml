let build_list n f = 
  match n with
  | 0 -> []
  | n -> List.init n f;;

build_list 8 (fun x -> x * 2);;

let negatives n = build_list n (fun x -> -(x + 1) );;

let reciprocals n = build_list n (fun x -> (1.0 /. float_of_int (x + 1) ) );;

let evens n = build_list n (fun x -> 2 * (x+1) );;

let identityM n = build_list n (fun x -> build_list n (fun i -> if i = x then 1 else 0 ) );;

negatives 8;;
reciprocals 8;;
evens 8;;
identityM 3;;