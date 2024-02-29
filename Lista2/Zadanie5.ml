let rec __maximum xs acc = 
  match xs with 
  | [] -> acc
  | x :: xs when acc > x -> __maximum (List.tl xs) acc
  | x :: xs -> __maximum (List.tl xs) x
  
  
let rec maximum xs = __maximum xs neg_infinity;;

print_endline (string_of_float (maximum [8.;2.;3.;4.]));;
