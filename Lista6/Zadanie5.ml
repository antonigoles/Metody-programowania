let rec parens_ok str = 
  let try_continue p callback =
    if p = 0 then (fun _ _ _ _ -> false) else callback 
  in let rec iterate xs p1 p2 p3 = 
    match xs with
    | [] -> ((p1 = 0) && (p2 = 0) && (p3 = 0))
    | x :: xs -> 
      match x with 
      | '(' -> iterate xs (p1+1) p2 p3
      | ')' -> (try_continue p1 iterate) xs (p1-1) p2 p3
      | '{' -> iterate xs p1 (p2+1) p3
      | '}' -> (try_continue p2 iterate) xs p1 (p2-1) p3
      | '[' -> iterate xs p1 p2 (p3+1)
      | ']' -> (try_continue p3 iterate) xs p1 p2 (p3-1)
      | _ -> false
  in iterate (str |> String.to_seq |> List.of_seq) 0 0 0;; 

parens_ok "([{[{{}}]}])";; (* true *)
parens_ok "([{[{{}])";; (* false *)
parens_ok "[()[{}]]";; (* true *)
