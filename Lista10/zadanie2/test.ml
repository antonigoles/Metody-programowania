let next =
  let x = ref 0 in
  fun y -> x := ! x + 1; ! x
  in
  next 0 + next 0