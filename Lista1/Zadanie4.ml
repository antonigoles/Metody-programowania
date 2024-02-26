let f = fun x y z -> 
  let min = fun a b -> if a < b then a else b in 
  let m = min (min x y) (min y z) in
  x * x + y * y + z * z - m * m;;

f 8 2 3;;