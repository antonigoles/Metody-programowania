let product xs = 
  match xs with
  | [] -> 0
  | a :: xs -> List.fold_left (fun acc x -> acc * x ) a xs;;


(product [1; 2; 3; 4]);;
(product [0; 2]);;
(product []);;