let rec parens_ok str = 
  let rec iterate xs p = 
    match xs with
    | [] -> (p = 0)
    | x :: xs -> 
      if x = '(' then (iterate xs (p+1))
      else if p = 0 then false else (iterate xs (p-1))
  in iterate (str |> String.to_seq |> List.of_seq) 0;; 

parens_ok "(())";;
parens_ok "(()";;
parens_ok "())";;
parens_ok ")(";;
parens_ok "(()()())";;
parens_ok "(x)";;